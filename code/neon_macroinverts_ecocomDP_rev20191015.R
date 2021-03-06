library(tidyverse)

# Install and load devtools
# install.packages("devtools")
library(devtools)

# Install and load dev version of ecocomDP
# install_github("EDIorg/ecocomDP", ref = 'development')
library(ecocomDP)

# Install and load neonUtilities
# install_github("NEONScience/NEON-utilities/neonUtilities", dependencies=TRUE)
library(neonUtilities)

#################################################################################
# beetle dpid
my_dpid <- 'DP1.20120.001'
my_site_list <- c('COMO', 'ARIK')

all_tabs <- neonUtilities::loadByProduct(
  dpID = my_dpid,
  site = my_site_list,
  check.size = TRUE)


# download field data for all dates for two neon sites -- much more manageable 
inv_fielddata <- all_tabs$inv_fieldData

# download beetle counts for two sites 
inv_taxonomyProcessed <- all_tabs$inv_taxonomyProcessed


# REQUIRED TABLES -- format for 

# location
table_location <- inv_fielddata %>%
  select(namedLocation, decimalLatitude, decimalLongitude, elevation) %>%
  distinct() %>%
  rename(
    location_id = namedLocation,
    latitude = decimalLatitude,
    longitude = decimalLongitude
  )

# taxon
table_taxon <- inv_taxonomyProcessed %>%
  select(acceptedTaxonID, taxonRank, scientificName) %>%
  distinct() %>%
  rename(taxon_id = acceptedTaxonID,
         taxon_rank = taxonRank,
         taxon_name = scientificName)

# observation
table_observation <- inv_taxonomyProcessed %>% 
  select(uid,
         sampleID,
         namedLocation, 
         collectDate,
         subsamplePercent,
         individualCount,
         estimatedTotalCount,
         acceptedTaxonID) %>%
  left_join(inv_fielddata %>% select(sampleID, benthicArea)) %>%
  mutate(variable_name = 'density',
         value = estimatedTotalCount / benthicArea,
         unit = 'count per square meter') %>% rename(observation_id = uid,
         event_id = sampleID,
         # package_id = NA,
         location_id = namedLocation,
         observation_datetime = collectDate,
         taxon_id = acceptedTaxonID) %>%
  mutate(package_id = NA) %>%
  select(observation_id, event_id, package_id,
           location_id, observation_datetime,
           taxon_id, variable_name, value, unit)

###################################
# write out in ecocomDP format
###
readr::write_csv(
  table_location,
  'table_location.csv')

readr::write_csv(
  table_taxon,
  'table_taxon.csv')

readr::write_csv(
  table_observation,
  'table_observation.csv')
