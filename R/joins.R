library(microbenchmark)
library(tidyverse)
library(data.table)


each_num <- 1e4

animal_legs <- map_dfr(data.frame(animal = c("cow", "fish", "chicken", "dog", "sheep"),
                          n_legs = c(4, 0, 2, 4, 4)), rep, each = each_num) %>% mutate(n = 1:nrow(.))

animal_sounds <- map_dfr(data.frame(animal = c("cow", "chicken", "cat", "sheep", "dog"),
                            sounds = c("mooo", "cluck", "meow", "baaa", "bark")),
                            rep, each = each_num) %>% mutate(n = 1:nrow(.))

# make a copy for setDT because it changes things in place,
# which would affect everything else relying on animal_legs and animal_sounds
# in microbenchmark.
animal_legs_2 <- copy(animal_legs)
animal_sounds_2 <- copy(animal_sounds)

# data.table for dtA test
animal_legs_dt <- data.table::data.table(animal_legs, key = "n")
animal_sounds_dt <- data.table::data.table(animal_sounds, key = "n")


microbenchmark::microbenchmark(
  base = base::merge(animal_legs, animal_sounds, by = "n", all = FALSE),
  ij = dplyr::inner_join(animal_legs, animal_sounds, by = "n"),
  dt = {
    animal_legs_dt_test <- data.table::data.table(animal_legs, key = "n")
    animal_sounds_dt_test <- data.table::data.table(animal_sounds, key = "n")
    animal_legs_dt_test[animal_sounds_dt_test, nomatch = NULL, on = .(n)] # inner join
  },
  dtA = animal_legs_dt[animal_sounds_dt, nomatch = NULL, on = .(n)],
  as_dt = {
    animal_legs_dt_test <- data.table::as.data.table(animal_legs, key = "n")
    animal_sounds_dt_test <- data.table::as.data.table(animal_sounds, key = "n")
    animal_legs_dt_test[animal_sounds_dt_test, nomatch = NULL, on = .(n)] 
  },
  set_dt = setDT(animal_legs_2)[setDT(animal_sounds_2), nomatch = NULL, on = .(n)]
)
