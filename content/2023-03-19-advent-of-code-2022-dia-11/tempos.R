dados <- read.csv('tempos.csv.gz')
dados$tempo = dados$tempo / 1000000000

library(svglite)
svglite('tempos.svg', width = 5, height = 5)
plot(
  dados$rodada,
  dados$tempo,
  type = 'l',
  xlab = 'Rodada',
  ylab = 'Tempo de Execução (segundos)',
  main = 'Tempo de cálculo de cada rodada',
  col = '#185aa9'
)
