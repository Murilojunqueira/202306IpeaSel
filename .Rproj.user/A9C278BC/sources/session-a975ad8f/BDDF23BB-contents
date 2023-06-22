# Seleção Chamada Pública IPEA/PNPD Nº030/2023 

# By Murilo Junqueira (m.junqueira@yahoo.com.br)

# Created at 2023-06-13


# Formata Tabela 'Governos' ####

Ufs <- fread("data/dataset/UFs.csv", encoding = "Latin-1")

Municipios <- fread("data/dataset/Municipios.csv", encoding = "Latin-1")

Governos_Id <- Ufs %>% 
  rename(Governo_Id = UF_Id) %>% 
  bind_rows(select(
    rename(
      Municipios, 
      Governo_Id = Munic_Id), 
    Governo_Id)) %>% 
  select(Governo_Id) %>% 
  mutate(Governo_Tipo = ifelse(nchar(Governo_Id) == 2, "Estado", "Municipio"))
  

fwrite(Governos_Id, "data/dataset/Governos.csv",
       sep = ";", dec = ",")
  
rm(Ufs, Municipios, Governos_Id)

# Cria tabela OSC ####


# Utilizando a tabela "area_subarea.xlsx":

library(readxl)

area_subarea <- read_xlsx("data/raw/area_subarea.xlsx", 
                          sheet = "area_subarea")

area_subarea <- fread("data/raw/area_subarea.csv")


OSC <- area_subarea %>% 
  select(1, cd_identificador_osc, tx_razao_social_osc, tx_nome_fantasia_osc,
         dt_fundacao_osc, cd_natureza_juridica_osc)

fwrite(OSC, "data/dataset/OSC.csv", sep = ";", dec = ",")

rm(OSC)

# Cria tabelas de áreas e subáreas ####

names(area_subarea)

AreasAtuacao <- names(area_subarea)[13:23] %>% 
  enframe(name = NULL, value = "Area_Nome") %>% 
  mutate(Area_Id = row_number())


SubAreasAtuacao <- names(area_subarea)[25:68] %>% 
  enframe(name = NULL, value = "SubArea_Nome") %>% 
  mutate(Area_Id = NA,
         SubArea_Id = row_number()) %>% 
  select(SubArea_Id, Area_Id, SubArea_Nome)
  
# Fazendo a relação entre áreas e sub-áreas:
SubAreasAtuacao$Area_Id[25:26 - 24] <- 1 # Habitação
SubAreasAtuacao$Area_Id[27:29 - 24] <- 2 # Saúde
SubAreasAtuacao$Area_Id[30:32 - 24] <- 3 # Cultura e recreação
SubAreasAtuacao$Area_Id[33:41 - 24] <- 4 # Educação e pesquisa
SubAreasAtuacao$Area_Id[42:43 - 24] <- 5 # Assistência social
SubAreasAtuacao$Area_Id[44:45 - 24] <- 6 # Religião
SubAreasAtuacao$Area_Id[46:50 - 24] <- 7 # 	Associações patronais, profissionais e de produtores rurais
SubAreasAtuacao$Area_Id[51:53 - 24] <- 8 # Meio ambiente e proteção animal
SubAreasAtuacao$Area_Id[54:67 - 24] <- 9 # Desenvolvimento e defesa de direitos
SubAreasAtuacao$Area_Id[68 - 24] <- 10 # Outros


# Fazendo a vinculação entre áreas e OSC:

AreasAtuacao_OSC <- tibble(Area_id = integer(0), id_osc = integer(0))

for (i in seq_len(nrow(AreasAtuacao))) {
  # i <- 2
  
  message("Inserindo OSC da área: ", AreasAtuacao$Area_Nome[i])
  
  Area_i <- which(names(area_subarea) == AreasAtuacao$Area_Nome[i])
  
  OSC_Area <- area_subarea %>% 
    select(1, Area_i) %>% 
    na.omit() %>% 
    magrittr::set_names(c("id_osc", "Area_id")) %>% 
    mutate(Area_id = AreasAtuacao$Area_Id[i])
  
  AreasAtuacao_OSC <- bind_rows(AreasAtuacao_OSC, OSC_Area)
  
  rm(Area_i, OSC_Area)
}
rm(i)

fwrite(AreasAtuacao_OSC, "data/dataset/AreasAtuacao_OSC.csv", 
       sep = ";", dec = ",")

fwrite(AreasAtuacao, "data/dataset/AreasAtuacao.csv", 
       sep = ";", dec = ",")

# Inserindo a relação entre subáreas e OSC:

SubAreasAtuacao_OSC <- tibble(id_osc = integer(0), 
                              SubArea_id = integer(0),
                              Area_Id = integer(0))

for (i in seq_len(nrow(SubAreasAtuacao))) {
  # i <- 4
  
  message("Inserindo OSC da Subárea: ", SubAreasAtuacao$SubArea_Nome[i])
  
  SubArea_Nome <- SubAreasAtuacao$SubArea_Nome[i]
  
  OSC_SubArea <- area_subarea  %>% 
    select(1, all_of(SubArea_Nome)) %>% 
    na.omit() %>% 
    magrittr::set_names(c("id_osc", "SubArea_id"))  %>% 
    mutate(SubArea_id = SubAreasAtuacao$SubArea_Id[i], 
           Area_Id = SubAreasAtuacao$Area_Id[i])
  
  SubAreasAtuacao_OSC <- bind_rows(SubAreasAtuacao_OSC, OSC_SubArea)
  
  rm(SubArea_Nome, OSC_SubArea)
}
rm(i)

fwrite(SubAreasAtuacao_OSC, "data/dataset/SubAreasAtuacao_OSC.csv", 
       sep = ";", dec = ",")

fwrite(SubAreasAtuacao, "data/dataset/SubAreasAtuacao.csv", 
       sep = ";", dec = ",")

rm(AreasAtuacao_OSC, AreasAtuacao, SubAreasAtuacao_OSC, SubAreasAtuacao)

ls()

# Fim