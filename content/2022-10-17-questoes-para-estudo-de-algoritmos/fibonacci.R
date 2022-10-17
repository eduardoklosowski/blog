library(svglite)
options(scipen=999)

dados <- read.csv('fibonacci.csv.gz')
dados <- aggregate(tempo ~ alg + n, dados, mean)
dados$tempo = dados$tempo / 1000000

svglite('fibonacci.svg', width = 5, height = 5)
plot(
  range(dados$n),
  c(0, max(dados$tempo)),
  type = 'n',
  xlab = 'n',
  ylab = 'Tempo de Execução (milissegundos)',
  main = 'Fibonacci'
)

algs = c('iterativo', 'recursivo')
legends = c('Iterativo', 'Recursivo')
pchs = c(21, 24)
ltys = c(2, 4)
cols = c('#ee2e2f', '#185aa9')
for (i in 1:length(algs)) {
  points(
    tempo ~ n,
    dados[dados$alg == algs[i],],
    type = 'p',
    pch = pchs[i],
    lty = ltys[i],
    col = cols[i]
  )
  points(
    tempo ~ n,
    dados[dados$alg == algs[i],],
    type = 'l',
    lty = pchs[i],
    pch = ltys[i],
    col = cols[i]
  )
}
legend(
  'topleft',
  bg = '#ffffff',
  legend = legends,
  pch = pchs,
  lty = ltys,
  col = cols
)
