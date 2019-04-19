#!/usr/bin/env python3
# process-populations.py - analyzes the data from the genetic algorithm for each generation
#
# Usage:
# >> python3 process-populations.py populations.csv


import sys
import os.path
import pandas as pd
from tabulate import tabulate


# show information of each generation
def main(filename):
  df_raw = pd.read_csv(filename)
  df_raw.dropna(inplace=True)   # remove invalid values
  # intialize df
  df_summary = pd.DataFrame()
  df_avg = pd.DataFrame()
  population_size = len(df_raw['genome'].unique())

  # get data from each generation
  generations = df_raw['generation'].unique()
  for generation in generations:
    df_gen = df_raw[(df_raw['generation'] == generation)]
    row_std = pd.DataFrame([[generation,
                      df_gen['fitness'].max(),
                      df_gen['complete_lines'].std(),
                      df_gen['aggregate_height'].std(),
                      df_gen['holes'].std(),
                      df_gen['bumpiness'].std()]],
                      columns=['generation',
                              'max_fitness',
                              'complete_lines_std',
                              'aggregate_height_std',
                              'holes_std',
                              'bumpiness_std']
                      )
    df_summary = df_summary.append(row_std)

    # get fittest 50% of each generation
    df_gen_fittest = df_gen[(df_gen['genome'] > population_size * .5)]
    row_avg = pd.DataFrame([[generation,
                      df_gen_fittest['fitness'].mean(),
                      df_gen_fittest['complete_lines'].mean(),
                      df_gen_fittest['aggregate_height'].mean(),
                      df_gen_fittest['holes'].mean(),
                      df_gen_fittest['bumpiness'].mean()]],
                      columns=['generation',
                              'fitness_avg',
                              'complete_lines_avg',
                              'aggregate_height_avg',
                              'holes_avg',
                              'bumpiness_avg']
                      )
    df_avg = df_avg.append(row_avg)

  df_summary.set_index('generation', inplace=True)
  df_avg.set_index('generation', inplace=True)
  print('Standard Deviation of the Entire population')
  print(tabulate(df_summary, headers='keys', tablefmt='psql', floatfmt='.3f'))
  print('\nAverage Heuristics of the Fittest 50% of Population')
  print(tabulate(df_avg, headers='keys', tablefmt='psql', floatfmt='.3f'))


if __name__ == '__main__':
  if len(sys.argv) != 2:
    sys.exit(f'Usage: python3 {program} population.csv')
  elif not os.path.isfile(sys.argv[1]):
    sys.exit('"{}" does not exist'.format(sys.argv[1]))
  main(sys.argv[1])
