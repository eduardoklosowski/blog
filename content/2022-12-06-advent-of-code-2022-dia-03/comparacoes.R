library(svglite)

calc_arvore <- function(n) {
    sum(floor(log2(1:n)) + 1) + n * floor(log2(n) + 2)
}

svglite('comparacoes.svg', width = 5, height = 5)
n <- 15
plot(
  c(0, n),
  c(0, n**2),
  type = 'n',
  xlab = 'n',
  ylab = 'Comparações',
  main = 'Quantidade de Comparações'
)
points(
  1:n,
  (1:n) ** 2,
  type = 'b',
  pch = 21,
  lty = 2,
  col = '#ee2e2f'
)
points(
  1:n,
  sapply(1:n, calc_arvore),
  type = 'b',
  pch = 24,
  lty = 4,
  col = '#185aa9'
)
legend(
  'topleft',
  bg = '#ffffff',
  legend = c('Lista', 'Conjunto'),
  pch = c(21, 24),
  lty = c(2, 4),
  col = c('#ee2e2f', '#185aa9')
)
