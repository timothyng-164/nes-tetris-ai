require("play_game")



--//------------------------------------------------------
--// genetic algorithm functions

function init_heuristic_params(a, b, c, d, fit_score)
  return {
    aggregate_height = a or 0,
    complete_lines = b or 0,
    holes = c or 0,
    bumpiness = d or 0,
    fitness = fit_score or nil
  }
end

-- return a list of randomly generated heuristic parameters
function init_population(pop_size, move_limit)
  print("Generating population with", pop_size, "genomes")
  population = {}
  for i=1, pop_size do
    temp_genome = init_heuristic_params(
      random_real_number(-1, 1, 3),
      random_real_number(-1, 1, 3),
      random_real_number(-1, 1, 3),
      random_real_number(-1, 1, 3))
    print()
    print("Generation: 1")
    print("Genome:", i)
    print_heuristics(temp_genome)

    temp_genome.fitness = play_game(temp_genome, move_limit)
    table.insert(population, temp_genome)
    print("fitness:", temp_genome.fitness)
  end
  return population
end

-- play through each genome from population and set fitness for each
function set_population_fitness(population, move_limit, generation)
  local temp_population = deepcopy(population)
  for i=1, #temp_population do
    -- get fitness of new genome
    if (not temp_population[i].fitness) then
      print()
      print("Generation:", generation)
      print("New child genome:", i)
      print_heuristics(temp_population[i])
      temp_population[i].fitness = play_game(temp_population[i], move_limit)
      print("fitness:", temp_population[i].fitness)
    end
  end
  return temp_population
end



--//------------------------------------------------------
--// crossover and selection functions

-- create child with 2 parents, weighted by fitness
function crossover(parent_1, parent_2, mutation_rate)
  local normalized_fitness_1, normalized_fitness_2 = unpack(normalize(parent_1.fitness, parent_2.fitness))
  local child = {
    aggregate_height = parent_1.aggregate_height * normalized_fitness_1 + parent_2.aggregate_height * normalized_fitness_2,
    complete_lines = parent_1.complete_lines * normalized_fitness_1 + parent_2.complete_lines * normalized_fitness_2,
    holes = parent_1.holes * normalized_fitness_1 + parent_2.holes * normalized_fitness_2,
    bumpiness = parent_1.bumpiness * normalized_fitness_1 + parent_2.bumpiness * normalized_fitness_2,
    fitness = nil
  }
  child = mutate_genome(child, mutation_rate)
  child = round_heuristic_params(child, 3)
  return child
end

-- return genome with a chance to mutate an anttribute
function mutate_genome(genome, mutation_rate, lower, upper)
  local mutated_genome = deepcopy(genome)
  if (math.random(1, 100) <= mutation_rate * 100) then
    local key = get_random_key(genome)
    while (key == "fitness") do key = get_random_key(genome) end
    mutated_genome[key] = mutated_genome[key] + random_real_number(lower or -1, upper or 1, 3)
  end
  return mutated_genome
end

-- return weights of 2 values
function normalize(val_1, val_2)
  local sum = val_1 + val_2
  if sum == 0 then return {.5, .5} end      -- divide by zero
  local normalized_val_1 = val_1 / sum
  local normalized_val_2 = val_2 / sum
  return {normalized_val_1, normalized_val_2}
end


-- return a table of randomly selected genomes from population
-- only a certain percentage of the population is selected
function select_genomes(population, selection_rate)
  local random_population = shuffle(deepcopy(population))
  local selected = {}

  local num_selected = math.floor(selection_rate * #population)
  for i=1, num_selected do
    table.insert(selected, random_population[i])
  end
  return selected
end



--//------------------------------------------------------
--// utility functions

function print_table(my_table)
  for key, value in pairs(my_table) do
    print(key, ":", value)
  end
end

function print_heuristics(genome)
  print("aggregate_height:", genome.aggregate_height)
  print("complete_lines:", genome.complete_lines)
  print("holes:", genome.holes)
  print("bumpiness:", genome.bumpiness)
end


-- return random key from table (lua doesn't index tables)
function get_random_key(my_table)
  local keyset = {}
  for k in pairs(my_table) do
      table.insert(keyset, k)
  end
  return keyset[math.random(#keyset)]
end


-- used to sort table by values
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- return population sorted by fitness from least to greatest
function sort_by_fitness(population)
  new_population = {}
  for index, genome in spairs(population, function(t, a, b) return t[b].fitness > t[a].fitness end) do
    local temp_genome = genome
    table.insert(new_population, temp_genome)
  end
  return new_population
end


-- randomly shuffle values in table (fisher-yates alg)
function shuffle(table)
    local output = { }
    local random = math.random()

    for index = 1, #table do
        local offset = index - 1
        local value = table[index]
        local randomIndex = offset*math.random()
        local flooredIndex = randomIndex - randomIndex%1

        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end
    return output
end


-- return random real number between lower and upper
function random_real_number(lower, upper, num_decimal_places)
  local rand = math.random() + math.random(lower, upper-1)
  return round(rand, num_decimal_places)
end

-- round all heuristic parameters in genome
function round_heuristic_params(genome, decimal_limit)
  local params = deepcopy(genome)
  params.aggregate_height = round(params.aggregate_height, decimal_limit)
  params.complete_lines = round(params.complete_lines, decimal_limit)
  params.holes = round(params.holes)
  params.bumpiness = round(params.bumpiness, decimal_limit)
  if (not params.fitness == nil) then
    params.fitness = round(params.fitness, decimal_limit)
  end
  return params
end

function round(num, num_decimal_places)
  local mult = 10^(num_decimal_places or 1)
  return math.floor(num * mult + 0.5) / mult
end


--//------------------------------------------------------
--// file logging functions

-- write string to file
function write_str(file_path, write_mode, str)
  local file = assert(io.open(file_path, write_mode))
  file:write(str)
  file:close()
end

-- write table as a row in csv file
function write_table(file_path, write_mode, table)
  local str = ""
  for key, value in pairs(table) do
    str = str .. value .. ","
  end
  str = str:sub(1, -2)  -- remove last comma from string
  write_str(file_path, write_mode, str)
end

function write_population(file_path, write_mode, population, generation)
  for i=1, #population do
    write_str(file_path, write_mode, generation .. ",")   -- write generation number
    write_str(file_path, write_mode, i .. ",")            -- write genome number
    write_table(file_path, write_mode, population[i])     -- write heuristic parameters
    write_str(file_path, write_mode, "\n")
  end
end


function datetime()
  local date_table = os.date("*t")
  local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
  local hour, minute, second = date_table.hour, date_table.min, date_table.sec
  local year, month, day = date_table.year, date_table.month, date_table.wday
  local result = string.format("%d-%d-%d_%d-%d-%d", year, month, day, hour, minute, second)
  return result
end
