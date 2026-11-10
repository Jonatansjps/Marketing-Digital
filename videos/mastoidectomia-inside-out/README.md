# Filme: Mastoidectomia inside-out

Monta um único vídeo com os arquivos da pasta **Mastoidectomia inside-out** do Google Drive,
na ordem em que foram **criados** (capturados no iPhone), não na ordem de upload.

## Como gerar

1. No Google Drive, baixe a pasta inteira (botão direito → Fazer download) e descompacte.
2. Instale o ffmpeg (Mac: `brew install ffmpeg exiftool imagemagick`).
3. Rode:

```bash
./montar_filme.sh ~/Downloads/Mastoidectomia\ inside-out mastoidectomia-inside-out.mp4
```

Opções: `FOTO_SEG=5` (tempo de cada foto), `TITULO="..."` (cartela de abertura; `TITULO=` remove),
`SEM_AUDIO=1` (tira o som ambiente), `ORIENTACAO=horizontal|vertical`.

## O que o script faz

- Ordena pela data de captura (exiftool) ou, sem exiftool, pelo número `IMG_xxxx`.
- Ignora cópias duplicadas (a pasta tem IMG_2541, 2547 e 2548 enviadas duas vezes).
- Cartela de abertura → cada vídeo com fade de entrada/saída → fotos com zoom lento.
- Formato automático pela orientação dos vídeos (1080x1920 ou 1920x1080), H.264/AAC 30 fps.

## Ordem esperada (pelo número do iPhone)

| # | Arquivo | Tipo |
|---|---------|------|
| 1 | IMG_2534 | vídeo |
| 2 | IMG_2535 | vídeo |
| 3 | IMG_2536 | vídeo |
| 4 | IMG_2538 | vídeo |
| 5 | IMG_2539 | vídeo |
| 6 | IMG_2540 | vídeo |
| 7 | IMG_2541 | foto (14:33:22) |
| 8 | IMG_2542 | vídeo |
| 9 | IMG_2543 | vídeo |
| 10 | IMG_2544 | vídeo |
| 11 | IMG_2545 | vídeo |
| 12 | IMG_2546 | vídeo |
| 13 | IMG_2547 | foto (14:52:26) |
| 14 | IMG_2548 | foto (14:52:27) |
