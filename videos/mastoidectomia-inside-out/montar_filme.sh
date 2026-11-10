#!/usr/bin/env bash
# Monta o filme "Mastoidectomia inside-out" com os vídeos e fotos de uma pasta,
# na ordem em que foram CRIADOS (data de captura do iPhone), não na ordem de upload.
#
# Uso:
#   ./montar_filme.sh /caminho/da/pasta [saida.mp4]
#
# Requisitos: ffmpeg (obrigatório). Opcionais: exiftool (lê a data de captura
# de fotos e vídeos) e ImageMagick/heif-convert/sips (converte HEIC).
# Sem exiftool, a ordem segue o número IMG_xxxx, que o iPhone gera em sequência.
#
# Variáveis opcionais:
#   FOTO_SEG=4        segundos que cada foto fica na tela
#   FADE=0.4          duração do fade de entrada/saída de cada trecho
#   TITULO="..."      texto da cartela de abertura (vazio = sem cartela)
#   ORIENTACAO=auto   auto | vertical | horizontal
#   SEM_AUDIO=0       1 = remove o áudio original dos vídeos
set -euo pipefail

PASTA="${1:?Informe a pasta com os arquivos}"
SAIDA="${2:-mastoidectomia-inside-out.mp4}"
FOTO_SEG="${FOTO_SEG:-4}"
FADE="${FADE:-0.4}"
TITULO="${TITULO-Mastoidectomia inside-out}"
ORIENTACAO="${ORIENTACAO:-auto}"
SEM_AUDIO="${SEM_AUDIO:-0}"
FPS=30

command -v ffmpeg >/dev/null || { echo "ffmpeg não encontrado"; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# ---------- 1. Lista os arquivos, sem duplicatas ----------
declare -A VISTO
LISTA="$TMP/lista.tsv"; : > "$LISTA"
shopt -s nullglob nocaseglob
for f in "$PASTA"/*.{mov,mp4,m4v,heic,jpg,jpeg,png}; do
  base="$(basename "$f")"
  # cópias do tipo "IMG_2547 (1).HEIC" e arquivos idênticos são ignorados
  [[ "$base" =~ \([0-9]+\)\. ]] && { echo "ignorando cópia: $base"; continue; }
  hash="$(cksum < "$f" | cut -d' ' -f1-2)"
  [[ -n "${VISTO[$hash]:-}" ]] && { echo "ignorando duplicata: $base"; continue; }
  VISTO[$hash]=1

  data=""
  if command -v exiftool >/dev/null; then
    data="$(exiftool -s3 -d '%Y%m%d%H%M%S' -api QuickTimeUTC \
      -CreationDate -DateTimeOriginal -CreateDate "$f" 2>/dev/null | head -1 || true)"
  fi
  num="$(echo "$base" | grep -oE '[0-9]+' | tail -1 || true)"
  printf '%s\t%010d\t%s\n' "${data:-0}" "${num:-0}" "$f" >> "$LISTA"
done
shopt -u nocaseglob

[[ -s "$LISTA" ]] || { echo "Nenhum vídeo/foto em $PASTA"; exit 1; }
sort -t$'\t' -k1,1 -k2,2n "$LISTA" | cut -f3 > "$TMP/ordem.txt"
echo "== Ordem de criação =="; nl -w2 -s'. ' <(xargs -d'\n' -n1 basename < "$TMP/ordem.txt")

# ---------- 2. Define o formato do filme ----------
eh_video() { [[ "${1,,}" =~ \.(mov|mp4|m4v)$ ]]; }
if [[ "$ORIENTACAO" == auto ]]; then
  ORIENTACAO=vertical
  while read -r f; do
    if eh_video "$f"; then
      # largura/altura já considerando a rotação gravada pelo iPhone
      read -r w h rot < <(ffprobe -v error < /dev/null -select_streams v:0 \
        -show_entries stream=width,height:stream_side_data=rotation \
        -of default=nw=1:nk=1 "$f" | tr '\n' ' ') || true
      rot="${rot:-0}"; rot="${rot#-}"
      [[ "$rot" == 90 || "$rot" == 270 ]] && { t=$w; w=$h; h=$t; }
      (( w > h )) && ORIENTACAO=horizontal
      break
    fi
  done < "$TMP/ordem.txt"
fi
if [[ "$ORIENTACAO" == horizontal ]]; then W=1920; H=1080; else W=1080; H=1920; fi
echo "== Formato: ${W}x${H} ($ORIENTACAO) =="

ENC=(-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r $FPS
     -c:a aac -b:a 160k -ar 48000 -ac 2 -video_track_timescale 30000)
# encaixa sem distorcer: fundo desfocado do próprio quadro + imagem centralizada
ENCAIXE="split[a][b];[a]scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H},boxblur=30:5,eq=brightness=-0.15[bg];[b]scale=${W}:${H}:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1,format=yuv420p"

# ---------- 3. Converte cada trecho para o mesmo padrão ----------
converte_foto() {  # $1 entrada, $2 jpg de saída
  case "${1,,}" in
    *.heic)
      if command -v magick >/dev/null; then magick "$1" -auto-orient "$2"
      elif command -v heif-convert >/dev/null; then heif-convert "$1" "$2" >/dev/null
      elif command -v sips >/dev/null; then sips -s format jpeg "$1" --out "$2" >/dev/null
      else ffmpeg -nostdin -v error -y -i "$1" "$2"; fi ;;
    *) cp "$1" "$2" ;;
  esac
}

i=0; : > "$TMP/concat.txt"
if [[ -n "$TITULO" ]]; then
  T=3.5; TXT="$TMP/titulo.txt"; printf '%s' "$TITULO" > "$TXT"
  ffmpeg -nostdin -v error -y -f lavfi -i "color=c=black:s=${W}x${H}:r=$FPS:d=$T" \
    -f lavfi -i "anullsrc=r=48000:cl=stereo" -t $T \
    -vf "drawtext=textfile='$TXT':fontcolor=white:fontsize=$((W/14)):x=(w-tw)/2:y=(h-th)/2,fade=in:0:d=0.8,fade=out:st=$(echo "$T-0.8"|bc):d=0.8" \
    "${ENC[@]}" "$TMP/000.mp4"
  echo "file '$TMP/000.mp4'" >> "$TMP/concat.txt"
fi

while read -r f; do
  i=$((i+1)); out="$TMP/$(printf %03d $i).mp4"; base="$(basename "$f")"
  echo "[$i] $base"
  if eh_video "$f"; then
    dur="$(ffprobe -v error < /dev/null -show_entries format=duration -of csv=p=0 "$f")"
    fo="$(echo "$dur - $FADE" | bc)"
    temaudio="$(ffprobe -v error < /dev/null -select_streams a -show_entries stream=index -of csv=p=0 "$f" | head -1)"
    if [[ -n "$temaudio" && "$SEM_AUDIO" != 1 ]]; then
      AIN=(-i "$f"); AMAP="0:a:0"
    else
      AIN=(-f lavfi -i "anullsrc=r=48000:cl=stereo"); AMAP="1:a"
    fi
    ffmpeg -nostdin -v error -y -i "$f" "${AIN[@]}" -t "$dur" \
      -filter_complex "[0:v]fps=$FPS,${ENCAIXE},fade=in:0:d=$FADE,fade=out:st=$fo:d=$FADE[v];[$AMAP]aformat=sample_rates=48000:channel_layouts=stereo,afade=in:0:d=$FADE,afade=out:st=$fo:d=$FADE[a]" \
      -map "[v]" -map "[a]" "${ENC[@]}" "$out"
  else
    jpg="$TMP/foto_$i.jpg"; converte_foto "$f" "$jpg"
    fo="$(echo "$FOTO_SEG - $FADE" | bc)"; frames=$((FOTO_SEG*FPS))
    # zoom lento (efeito Ken Burns) para a foto não ficar parada
    ffmpeg -nostdin -v error -y -loop 1 -framerate $FPS -i "$jpg" -f lavfi -i "anullsrc=r=48000:cl=stereo" -t "$FOTO_SEG" \
      -filter_complex "[0:v]${ENCAIXE},scale=$((W*2)):$((H*2)),zoompan=z='min(1+0.0008*on,1.15)':x='iw/2-iw/zoom/2':y='ih/2-ih/zoom/2':d=$frames:s=${W}x${H}:fps=$FPS,fade=in:0:d=$FADE,fade=out:st=$fo:d=$FADE,format=yuv420p[v]" \
      -map "[v]" -map 1:a "${ENC[@]}" "$out"
  fi
  echo "file '$out'" >> "$TMP/concat.txt"
done < "$TMP/ordem.txt"

# ---------- 4. Junta tudo ----------
ffmpeg -nostdin -v error -y -f concat -safe 0 -i "$TMP/concat.txt" -c copy -movflags +faststart "$SAIDA"
echo "== Pronto: $SAIDA ($(ffprobe -v error < /dev/null -show_entries format=duration -of csv=p=0 "$SAIDA" | cut -d. -f1)s) =="
