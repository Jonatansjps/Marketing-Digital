---
name: plano-de-tratamento
description: Monta o plano de tratamento otorrinolaringológico do jeito que o Dr. Jônatans Parada pensa. Na primeira vez, entrevista o médico para registrar o raciocínio clínico dele num Perfil Clínico. Depois, a partir de idade, queixa e avaliação do paciente (texto ou áudio transcrito), entrega o plano em 2 versões, a técnica para o médico e uma apresentação elegante para o paciente. Use quando o pedido falar em plano de tratamento, conduta, proposta para paciente, orçamento de tratamento, ou quando chegar um caso clínico com idade, queixa e achados de exame (rinite, desvio de septo, cornetos, apneia, ronco, adenoide, amígdalas, sinusite, respiração oral). Também use quando pedirem para criar ou atualizar o Perfil Clínico.
---

# Plano de Tratamento — do jeito que o médico pensa

Esta skill trabalha em dois momentos:

1. **Entrevista (uma vez só):** aprende o raciocínio clínico do médico e gera o **Perfil Clínico**.
2. **Plano (a cada paciente):** recebe o caso e devolve o plano em **2 versões**: a técnica, para o médico, e a do paciente, para ele entender na hora.

Fale sempre em português do Brasil, com o tom de um colega organizado e direto.

---

## Passo 0: existe um Perfil Clínico?

Procure, nesta ordem:
- um arquivo `perfil-clinico.md` no projeto, no conhecimento do Project ou anexado na conversa;
- um bloco "PERFIL CLÍNICO" colado na conversa.

**Se existir:** diga em 1 linha "Perfil Clínico carregado: <resumo em ~10 palavras>" e siga para o **Passo 2**.
**Se não existir:** siga para o **Passo 1**. Se chegou um caso antes do perfil, avise que precisa do perfil primeiro e guarde o caso para depois.

---

## Passo 1: entrevista (gera o Perfil Clínico)

Leia `references/entrevista.md` e conduza a entrevista **um bloco por vez** (são 6 blocos). Regras:
- Mande o bloco inteiro de uma vez. O médico pode responder por áudio, em tópicos, como quiser.
- Se uma resposta vier vaga ("depende"), faça **no máximo 1** pergunta de follow-up pedindo um exemplo real ("Me conta o último caso em que você fez isso").
- Ao final, gere o Perfil Clínico **exatamente** no formato de `references/modelo-perfil-clinico.md`, usando as palavras do médico sempre que possível.
- Entregue o perfil como arquivo `perfil-clinico.md` e oriente: "Salve este arquivo no conhecimento do Project (ou anexe nas próximas conversas). É ele que faz o plano sair do seu jeito."
- Nunca preencha uma seção do perfil com suposição. Se o médico não respondeu, escreva `A DEFINIR`.

---

## Passo 2: montar o plano

### 2.1 Ler o caso
Entrada típica (texto ou áudio transcrito): idade, sexo, queixa principal, tempo de evolução, tratamentos anteriores, achados de exame (oroscopia, rinoscopia, nasofibroscopia, otoscopia), exames complementares (TC de seios, polissonografia, audiometria) e restrições do paciente (orçamento, agenda, medo de cirurgia).

Antes de montar, verifique se falta algo **que mude a conduta segundo o Perfil Clínico** (por exemplo, a polissonografia num paciente com ronco, se o perfil diz que ele sempre pede). Se faltar:
- pergunte em **uma única mensagem**, com no máximo 3 perguntas; ou
- se o médico disser "monta assim mesmo", monte e liste a lacuna em **Pendências**.

### 2.2 Raciocinar como o médico
Aplique o Perfil Clínico na ordem dele:
1. **Prioridades:** o que ele trata primeiro e por quê (ex.: controle clínico da rinite antes de indicar cirurgia).
2. **Critérios de indicação:** quando passa do clínico para o cirúrgico; tempo mínimo de tratamento clínico.
3. **Condutas preferidas por condição** (seção 4 do perfil).
4. **Fases e duração** típicas.
5. **Reavaliação:** quando e com quais critérios.
6. **O que ele nunca faz:** respeite sempre.

Se o caso cair fora de tudo o que o perfil cobre, diga isso claramente e proponha a conduta mais conservadora, marcada como `⚠ fora do Perfil Clínico — decidir`.

### 2.3 Entregar as 2 versões

**A) Versão técnica (para o médico)**, em Markdown, na conversa:

```
## Versão técnica: <iniciais>, <idade> anos

**Resumo do caso:** 2–3 linhas.
**Hipóteses diagnósticas:** em ordem de probabilidade (CID-10 se o perfil pedir).
**Achados que sustentam:** bullets.
**Raciocínio (por que nesta ordem):** 3–5 bullets ligando o caso ao Perfil Clínico ("segue sua regra: …").

### Plano por fase
| Fase | Período | Conduta | Objetivo | Critério para avançar |
|---|---|---|---|---|

**Exames a solicitar:** …
**Sinais de alerta / encaminhamentos:** …
**Reavaliação:** quando e o que medir (ex.: NOSE, Epworth, IAH).
**Investimento:** só se o perfil tiver valores; senão, "A DEFINIR pelo médico".
**Pendências e decisões suas:** lista curta.
```

**B) Versão do paciente**: uma página HTML elegante, baseada em `assets/template-paciente.html`:
- Linguagem simples, sem jargão; quando um termo técnico for inevitável, explique entre parênteses ("septo, a parede que divide o nariz").
- Bloco "O que você me contou" com a queixa **nas palavras do paciente**, se vierem no caso.
- 3 a 5 fases em linha do tempo: nome curto, período e o que acontece em cada uma.
- Bloco "O que esperar" com benefícios **realistas**, sem prometer resultado.
- Investimento só se o médico informou valores. Nunca invente preço.
- Selo **"Rascunho, aguardando revisão do Dr."** até o médico dizer que revisou. Só depois troque por "Revisado pelo Dr. Jônatans Parada".
- Identifique o paciente só pelo primeiro nome ou pelas iniciais.
- Publique como artifact (se a ferramenta existir) ou entregue o arquivo `.html`.

Termine com uma linha: "Quer ajustar algo? Ex.: 'troca a fase 2 por spray de corticoide por 90 dias' ou 'tira o valor'."

### 2.4 Ajustes
Ajustes pedidos na conversa atualizam **as duas versões** juntas, mantendo uma coerente com a outra. Se o ajuste contrariar o Perfil Clínico, aplique e pergunte em 1 linha: "Isso vira regra no seu perfil?". Se a resposta for sim, gere o trecho atualizado do `perfil-clinico.md`.

---

## Regras inegociáveis

- **O médico decide.** O plano é um rascunho de apoio; nada vai para o paciente sem revisão dele.
- **Nunca invente** achado, exame, dose, preço ou estatística de sucesso. Se faltar, é `A DEFINIR` ou vai para Pendências.
- **Doses e medicamentos:** use só os que estão no Perfil Clínico. Se precisar de algo fora dele, escreva o nome da classe ("corticoide nasal") e marque para o médico definir.
- **Ética médica (CFM):** a versão do paciente não promete resultado, não usa "garantido", "definitivo", "100%", não usa antes/depois e não faz comparação depreciativa com outros profissionais.
- **LGPD:** sem nome completo, CPF, telefone ou endereço do paciente. Se vierem no caso, ignore e avise uma vez.
- **Sinais de alerta** (ex.: sangramento unilateral, massa cervical, perda auditiva súbita, apneia grave com sonolência ao dirigir, criança com pausas respiratórias importantes) sempre aparecem destacados no topo da versão técnica.
