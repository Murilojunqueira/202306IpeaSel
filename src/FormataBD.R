# Seleção Chamada Pública IPEA/PNPD Nº030/2023 

# By Murilo Junqueira (m.junqueira@yahoo.com.br)

# Created at 2023-06-13

# Pacotes básicos de sobrevivência:
library(tidyverse)
library(data.table)
library(stringr)
library(assertthat)


# Options
options(stringsAsFactors = FALSE)
options(encoding = "utf-8")
options(dplyr.summarise.inform = FALSE)


# Formata Tabela 'Governos' ####

# Carrega Dados prévios sobre os estados:
Ufs <- fread("data/dataset/UFs.csv", encoding = "Latin-1")

# Carrega dados prévios sobre os municípios:
Municipios <- fread("data/dataset/Municipios.csv", encoding = "Latin-1")

# Empilha chaves-primárias de estados e municípios, adiciona a variável Governo_Tipo
Governos_Id <- Ufs %>% 
  rename(Governo_Id = UF_Id) %>% 
  bind_rows(select(
    rename(
      Municipios, 
      Governo_Id = Munic_Id), 
    Governo_Id)) %>% 
  select(Governo_Id) %>% 
  mutate(Governo_Tipo = ifelse(nchar(Governo_Id) == 2, "Estado", "Municipio"))
  
# Salva os dados em csv
fwrite(Governos_Id, "data/dataset/Governos.csv",
       sep = ";", dec = ",")

# Limpa a memória
rm(Ufs, Municipios, Governos_Id)

# Cria tabela OSC ####


# Utilizando a tabela "area_subarea.xlsx":

# Carrega o pacote 'readxl', para ler dados em MS Excel.
library(readxl)

# Carrega dados do Excel
area_subarea <- read_xlsx("data/raw/area_subarea.xlsx", 
                          sheet = "area_subarea")

area_subarea <- fread("data/raw/area_subarea.csv")

names(area_subarea)

# Cria a tabela OSC
OSC <- area_subarea %>% 
  # Seleciona apenas variáveis relevantes.
  select(1, cd_identificador_osc, tx_razao_social_osc, tx_nome_fantasia_osc,
         dt_fundacao_osc, cd_natureza_juridica_osc, edmu_cd_municipio) %>% 
  # Renomeia a variável do código municipal:
  rename(Munic_Id = edmu_cd_municipio)

# Salva os dados em csv
fwrite(OSC, "data/dataset/OSC.csv", sep = ";", dec = ",")

# Limpa a memória
rm(OSC)

# Cria tabelas de áreas e subáreas ####

# As áreas de atuação são os nomes das colunas 13 a 23 do banco 'area_subarea'.
AreasAtuacao <- names(area_subarea)[13:23] %>% 
  enframe(name = NULL, value = "Area_Nome") %>% 
  mutate(Area_Id = row_number())

# As subáreas de atuação são os nomes das colunas 24 a 68 do banco 'area_subarea'.
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


# Agora iremos criar um loop para, para cada área, encontrar as 
# OSC que atuam naquela área.

# O primeiro passo é criar um banco de dados em branco com as variáveis
# utilizadas:
AreasAtuacao_OSC <- tibble(Area_id = integer(0), id_osc = integer(0))

# Agora, para cada área, iremos rodar um loop.
for (i in seq_len(nrow(AreasAtuacao))) {
  
  # Uma mensagem para sabermos o que está acontecendo
  message("Inserindo OSC da área: ", AreasAtuacao$Area_Nome[i])
  
  # Encontramos o nome da área que estamos busando.
  Area_i <- which(names(area_subarea) == AreasAtuacao$Area_Nome[i])
  
  # Seleciona apenas as OSC que atuam naquela áreas.
  OSC_Area <- area_subarea %>% 
    select(1, Area_i) %>% 
    na.omit() %>% 
    magrittr::set_names(c("id_osc", "Area_id")) %>% 
    mutate(Area_id = AreasAtuacao$Area_Id[i])
  
  # Adiciona a relação entre área e OSC no banco:
  AreasAtuacao_OSC <- bind_rows(AreasAtuacao_OSC, OSC_Area)
  
  # Limpa a memória
  rm(Area_i, OSC_Area)
}
rm(i)

# Agora já podemos salvar as tabelas com a lista das áreas de atuação
# e a relação entre áreas e OSC:
fwrite(AreasAtuacao_OSC, "data/dataset/AreasAtuacao_OSC.csv", 
       sep = ";", dec = ",")

fwrite(AreasAtuacao, "data/dataset/AreasAtuacao.csv", 
       sep = ";", dec = ",")

# Aqui, basicamente repetimos o processo com as subáreas:

# criamos um banco de dados em branco:
SubAreasAtuacao_OSC <- tibble(id_osc = integer(0), 
                              SubArea_id = integer(0),
                              Area_Id = integer(0))

# Loop para cada subárea>
for (i in seq_len(nrow(SubAreasAtuacao))) {
  
  # Mensagem
  message("Inserindo OSC da Subárea: ", SubAreasAtuacao$SubArea_Nome[i])
  
  # Nome da subárea
  SubArea_Nome <- SubAreasAtuacao$SubArea_Nome[i]
  
  # Seleciona as OSC que atuam naquela subárea.
  OSC_SubArea <- area_subarea  %>% 
    select(1, all_of(SubArea_Nome)) %>% 
    na.omit() %>% 
    magrittr::set_names(c("id_osc", "SubArea_id"))  %>% 
    mutate(SubArea_id = SubAreasAtuacao$SubArea_Id[i], 
           Area_Id = SubAreasAtuacao$Area_Id[i])
  
  # Adiciona os dados ao banco
  SubAreasAtuacao_OSC <- bind_rows(SubAreasAtuacao_OSC, OSC_SubArea)
  
  # Limpa a memória
  rm(SubArea_Nome, OSC_SubArea)
}
rm(i)

# salva as bases de dados em csv.
fwrite(SubAreasAtuacao_OSC, "data/dataset/SubAreasAtuacao_OSC.csv", 
       sep = ";", dec = ",")

fwrite(SubAreasAtuacao, "data/dataset/SubAreasAtuacao.csv", 
       sep = ";", dec = ",")

# Limpa a memória
rm(AreasAtuacao_OSC, AreasAtuacao, SubAreasAtuacao_OSC, SubAreasAtuacao)

# Checa se a memória está limpa
ls()

# Fim