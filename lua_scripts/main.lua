require("genetic_alg")

--//------------------------------------------------------
--// main

do
  local population_size = 100
  local children_size = math.floor(population_size * .5)    -- get 50 children for every new generation
  local selection_rate = 0.5    -- select 10% of population for each crossover
  local mutation_rate = 0.02    -- 2% chance of mutation for each crossover
  local generation_limit = 2
  local generation = 1
  local move_limit = 300      -- move limit for each game played
  local file_name = "populations/populations_" .. datetime() .. ".csv"

  math.randomseed(os.time())
  assert(selection_rate * population_size >= 2)  -- must have 2 children to crossover
  assert(children_size >= 1)                     -- must have more than 1 child

  -- write header for csv file
  write_table(file_name, "w", {"generation", "genome", "fitness", "complete_lines", "aggregate_height", "holes", "bumpiness"})
  write_str(file_name, "a", "\n")

  -- begin genetic algorithm
  local population = init_population(population_size, move_limit)
  local population = sort_by_fitness(population)
  write_population(file_name, "a", population, generation)

  generation = generation + 1
  while (generation <= generation_limit) do
    set_random_addr()   -- randomly seed game pieces
    -- selection and crossover
    local children = {}
    for i=1, children_size do
      local selected = select_genomes(population, selection_rate)     -- randomly select a percentage of population
      selected = sort_by_fitness(selected)
      local fittest_genome_1, fittest_genome_2 = selected[#selected], selected[#selected-1]   -- get 2 fittest genomes from selection
      local child = crossover(fittest_genome_1, fittest_genome_2, mutation_rate)
      table.insert(children, child)

      -- -- print crossover results
      -- print()
      -- print("selected:", i)
      -- print_table(selected)
      -- print("fittest parent 1:", fittest_genome_1)
      -- print("fittest parent 2:", fittest_genome_2)
      -- print("child", i, ":", child)
    end

    -- in population, replace least fit genomes with new children
    for i=1, children_size do
      population[i] = children[i]
    end

    population = set_population_fitness(population, move_limit, generation)
    population = sort_by_fitness(population)
    write_population(file_name, "a", population, generation)
    generation = generation + 1

    print()
    print("Fittest genome in population:")
    print(population[#population])
  end

  print()
  print("Final fittest genome:")
  print(population[#population])

  write_str(file_name, "a", "\nPopulation size = " .. population_size .. "\n")
  write_str(file_name, "a", "Children size = " .. children_size .. "\n")
  write_str(file_name, "a", "selection rate = " .. selection_rate .. "\n")
  write_str(file_name, "a", "Mutation rate = " .. mutation_rate .. "\n")
  write_str(file_name, "a", "Move limit = " .. move_limit .. "\n")

end
