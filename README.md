Reformulação do Mapa das Organizações da Sociedade Civil (IPEA)
================

**Murilo Junqueira** (<m.junqueira@yahoo.com.br>)

### Objetivo do Projeto:

Demonstrar um modelo de reformulação dos dados atualmente disponíveis no
[Mapa das Organizações da Sociedade Civil
(OSC)](https://mapaosc.ipea.gov.br/).

### Os passos dessa reformulação são:

1.  Mapeamento das Bases Originais que compõem o Mapa
2.  Criação de um novo *schema* dos dados, representado por um diagrama
    entidade-relacionamento (DER)
3.  Validação do *schema* junto à direção do IPEA.
4.  Formatação dos dados originais no novo *schema*.
5.  Migração dos dados para, para um DBMS (*Data Base Management
    System*), PostgreSQL ou MySQL.
6.  Criação da documentação completa do banco, incluindo o fluxo
    administrativo.

Essa página visa descrever como se dá os passos 2 e 4, utilizando as
bases atualmente disponíveis no site [Site do Mapa das
(OSC)](https://mapaosc.ipea.gov.br/base-dados).

Os demais passos não são possíveis de serem feitos no momento.

### Definição de um novo *schema* para o Mapa das OSC

Com base nos dados disponíveis no [Mapa das
(OSC)](https://mapaosc.ipea.gov.br/base-dados), na aba “Dados \> Base de
dados”, elaboramos o seguinte modelo de dados:

#### Diagrama Entidade-Relacionamento (DER):

<figure>
<img src="data/metadata/dataModel_MySQL/BD_MapaOSC.png"
alt="Entity-relationship diagram" />
<figcaption aria-hidden="true">Entity-relationship diagram</figcaption>
</figure>

A figura do *schema* acima, em tamanho expandido, pode ser encontrada na
pasta “data/metadata/dataModel_MySQL/” deste repositório.

A criação deste modelo de dados foi feita com o princípio de reduzir ao
máximo a redundância dos dados (processo de “normalização” das bases de
dados), de modo a que cada informação apareça apenas uma vez. Abaixo
explicamos o significado de cada uma das tabelas e das conexões feitas.

#### Explicação do Diagrama Entidade-Relacionamento:

A tabela mais central do banco é a tabela **OSC**, que guarda os dados
básicos das Organizações da Sociedade Civil. Suas variáveis são:

- Tabela **OSC:**
  - **id_osc:** (chave-primária) identificação da OSC.
  - **Munic_Id:** código IBGE do município da sede da OSC.
  - **cd_identificador_osc:** outro número de indentificação das OSC.
  - **tx_razao_social_osc:** razão social da OSC.
  - **tx_nome_fantasia_osc:** nome fantasia da OSC.
  - **dt_fundacao_osc:** data de fundação da OSC.
  - **cd_natureza_juridica_osc:** natureza jurídica da OSC.
  - **cnae_divisao_corrigido:** divisão da CNAE que se encontra a OSC.
  - **cnae_grupo_corrigido:** grupo da CNAE.
  - **cnae_classe_corrigido:** classe da CNAE.
  - **cnae_subclase_corrigido:** sub-classe da CNAE.
  - **endereco:** endereço oficial da OSC.
  - **bairro:** bairro.
  - **macro_area_atuacao:** macro área de atuação da OSC.
  - **micro_area_atuacao:** micro área de atuação da OSC.

Na região noroeste do DER acima estão algumas tabelas destinadas a
guardas dados sobre as regiões administrativas brasileiras, ou seja, os
entes federativos. Optamos por criar uma tabela genérica “Governos” para
agregar todos os níveis federativos, dos municípios ao governo federal.
Isso é necessário porque em algumas tabelas a OSC pode ter atributos de
qualquer nível federativo. Por exemplo, ela pode ter um certificado
municipal (ex: Conselho Municipal de Assistência Social), mas também
pode ter um certificado estadual (ex: do Conselho Estadual de
Assistência Social ou de Saúde) e também do governo federal (ex:
Ministério da Justiça). O mesmo ocorre quanto a entidade tem assento em
conselhos de políticas públicas: ela pode ter acento em conselhos de
qualquer nível federativo. Então, criar colunas próprias para cada um
dos níveis federativos não é conveniente. Com a tabela intermediária
“Governos”, podemos criar a relação apenas com essa tabela. Para manter
a consistência e conexão nos dados, criamos duas relações “de um para
um” (1:1) entre as tabelas “Governos” e “Municipios”, bem como entre as
tabelas “Governos” e “UFs”. Em termos lógicos, podemos ler o seguinte:
alguns governos são municípios, mas não todos; da mesma forma, alguns
governos são Estados, mas não todos. Existe, inclusive o caso de dois
governos que não são nem Estados nem Municípios: o governo federal e o
Distrito Federal.

- Tabela **UFs:**
  - **Governo_Id:** (chave-primária) Identificação das unidades
    federativas.
  - **UF_Sigla:** sigla das UFs (ex: GO, ES).
  - **UF_CodIBGE:** código IBGE das UFs.
  - **UF_Nome:** nome da UF.
  - **UF_Regiao:** sigla da região da UF (ex: N, NE, CE, SE, S).
    <br><br>
- Tabela **Municipios:**
  - **Governo_Id:** (chave-primária) identificação dos municípios.
  - **Munic_COdIBGE:** código IBGE dos municípios.
  - **UF_Sigla:** (chave-estrangeira) sigla do Estado do município.
  - **Munic_Nome:** nome do município. <br><br>
- Tabela **Governos:**
  - **Governo_Id:** (chave-primária) identificação dos governos.
  - **Governo_Tipo:** o tipo de governo (município, estado, DF ou União)
    <br><br>

Na região sudoeste do mapa existe uma série de tabelas de caracterização
das OSC. A primeira são os certificados que a organização possui. Como
mencionado acima, cada certificado foi dado por um governo (que pode ser
a União, Estado ou Município). A tabela *Certificados* fala sobre as
características intrínsecas de cada certificado, mas não fala qual OSC
possui cada certificado. Isso é feito na tabela *OSC_Certificados*, que
estabelece uma relação “de muitos para muitos” (m:n) entre *OSC* e
*Certificados*. Os certificados possuem validade, que está guardado nas
variáveis *dt_inicio_certificado* e *dt_fim_certificado*.

- Tabela **Certificados:**
  - **Certificado_Id:** (chave-primária) indentificação do certificado.
  - **tx_nome_certificado:** nome do certificado.
  - **ft_certificado:** órgão que atribui o certificado. <br><br>
- Tabela **OSC_Certificados:**
  - **id_osc:** (chave-primária, chave-extrangeira) identificação da
    OSC.
  - **Certificado_Id:** (chave-primária) indentificação do certificado.
  - **Governo_Id:** (chave-estrangeira) governo que atribuiu o
    certificado.
  - **dt_inicio_certificado:** (chave-primária) data de início do
    certificado.
  - **dt_fim_certificado:** data de fim do certificado <br><br>

Ainda na região sudoeste do DER, existem informações sobre as áreas e
subáreas de atuação das OSC. A relação lógica estipulada no modelo de
dados é que cada subárea possui uma única área correspondente. As OSC
podem ter qualquer número de área ou subáreas em uma relação “de muitos
para muitos” (m:n).

- Tabela **AreasAtuacao:**
  - **Area_Id:** (chave-primária) identificação da área de atuação.
  - **Area_Nome:** Nome da área de atuação. <br><br>
- Tabela **AreasAtuacao_OSC:**
  - **Area_Id:** (chave-primária, chave-extrangeira) identificação da
    subárea de atuação.
  - **id_osc:** (chave-primária, chave-extrangeira) identificação da
    OSC. <br><br>
- Tabela **SubAreasAtuacao:**
  - **SubArea_Id:** (chave-primária) identificação da subárea de
    atuação.
  - **SubArea_Nome:** nome da subárea.
  - **Area_Id:** (chave-estrangeira) nome da área de atuação. <br><br>
- Tabela **SubAreasAtuacao_OSC:**
  - **SubArea_Id:** (chave-primária, chave-extrangeira) identificação da
    subárea de atuação.
  - **id_osc:** (chave-primária, chave-extrangeira) identificação da
    OSC. <br><br>

Na região nordeste do DER temos algumas informações sobre a atuação das
OSC, como participação em conselhos e conferências (no [Mapa das
(OSC)](https://mapaosc.ipea.gov.br/base-dados) essas duas informações
estavam juntas, mas o mais correto seria separar elas em tabelas
distintas), projetos desenvolvidos e arrecadação de recursos. As tabelas
*OSC_Conferencias* e *OSC_Conselhos* fazem a correspondências entre cada
OSC e as conferências e os conselhos, respectivamente.

- Tabela **Conferencias:**
  - **Conferencia_Id:** (chave-primária) identificação da conferência.
  - **Conferencia_Nome:** nome da conferência.
  - **Conferencia_DtInicio:** data de início da conferência.
  - **Conferencia_DtFim:** data de fim da conferência. <br><br>
- Tabela **OSC_Conferencias:**
  - **id_osc:** (chave-primária, chave-estrangeira) identificação da
    OSC.
  - **Conferencia_Id:** (chave-primária, chave-estrangeira)
    identificação da conferência.
  - **OSCConf_TipoParticipacao:** tipo de participação que a OSC teve na
    conferência. <br><br>
- Tabela **Conselhos:**
  - **Conselho_Id:** (chave-primária) identificação do conselho.
  - **tx_nome_conselho:** nome do conselho.
  - **tx_nome_orgao_vinculado:** nome do órgão governamental no qual o
    conselho é vinculado.
  - **tx_nome_periodicidade_reuniao_conselho:** periodicidade da reunião
    do conselho. <br><br>
- Tabela **OSC_Conselhos:**
  - **id_osc:** (chave-primária, chave-estrangeira) identificação da
    OSC.
  - **Conselho_Id:** (chave-primária, chave-estrangeira) identificação
    do conselho.
  - **dt_data_inicio_conselho:** data de início da participação da OSC
    no conselho.
  - **dt_data_fim_conselho:** data de fim da participação da OSC no
    conselho. <br><br>

A longa tabela dos “projeto” indica que muitas variáveis que estão nesta
única tabela possuem relações de “um para muitos” (1:m) ou “muitos para
muitos” (m:n). Certemente após uma análise mais detida das
características dos dados ela seria quebrada em várias tabelas.

- Tabela **Projetos:**
  - **id_projeto:** (chave-primária) identificação dos projetos.
  - **id_osc:** (chave-estrangeira) identificação da OSC.
  - **tx_nome_projeto:** nome do projeto.
  - **dt_data_inicio_projeto:** data de início do projeto.
  - **dt_data_fim_projeto:** data de fim do projeto.
  - **tx_link_projeto:** link para a página do convênio no portal
    ‘<https://www.convenios.gov.br>’.
  - **nr_total_beneficiarios:** número total de beneficiários do
    convêncio.
  - **nr_valor_captado_projeto:** valor captado para o projeto.
  - **nr_valor_total_projeto:** valor total do projeto.
  - **tx_nome_abrangencia_projeto:** abrangência do projeto.
  - **tx_nome_zona_atuacao:** nome da zona de atuação do projeto.
  - **tx_descricao_projeto:** descrição do projeto.
  - **tx_metodologia_monitoramento:** metodologia de monitoramento do
    projeto.
  - **ft_identificador_projeto_externo:** identificador do projeto no
    órgão externo.
  - **tx_status_projeto_outro:** status do projeto.
  - **tx_nome_financiador:** nome do financiador do projeto.
  - **tx_orgao_concedente:** nome do órgão concedente do projeto.
  - **tx_nome_origem_fonte_recursos_projeto:** nome da origem dos
    recursos do projeto.
  - **tx_nome_fonte_recursos_projeto:** nome da fonte dos recursos do
    projeto.
  - **tx_nome_regiao_localizacao_projeto:** região de localização do
    projeto.
  - **tx_nome_objetivo_projeto:** objetivo do projeto.
  - **tx_nome_meta_projeto:** meta do projeto.
  - **tx_nome_publico_beneficiado:** nome dos beneficiados do projeto.
  - **nr_estimativa_pessoas_atendidas:** estimativa de pessoas atendidas
    pelo projeto.
  - **tx_nome_tipo_parceria:** nome do tipo de parceria estabelecida
    para o projeto. <br><br>
- Tabela **Recursos:**
  - **Recurso_Id:** (chave-primária) identificação dos recursos.
  - **id_osc:** (chave-estrangeira) identificação da OSC.
  - **tx_nome_fonte_recursos_osc:** nome da fonte dos recursos.
  - **dt_ano_recursos_osc:** ano em que os recursos foram arrecadados.
  - **nr_valor_recursos_osc:** valor dos recursos.
  - **ft_fonte_recursos_osc:** nome do órgão que concedeu os recursos.
    <br><br>

Por fim, na região sudeste do DER, existe algumas tabelas sobre as
“pessoas”. Elas são informações sobre a diretoria e os diretores da OSC
e também sobre o número de pessoas empregadas, segundo a RAIS (Relação
Anual de Informações Sociais), vinculada ao Ministério do Trabalho.

- Tabela **Diretoria:**
  - **Diretoria_Id:** (chave-primária) identificação da diretoria.
  - **id_osc:** (chave-estrangeira) identificação da OSC.
  - **ano:** Ano do relatório de prestação de contas.
  - **nm_diretor:** nome do diretor .
  - **nm_cargo:** Cargo do diretor.
  - **in_empregado_publico:** Indicador de que o diretor é funcionário
    público. <br><br>
- Tabela **Diretores:**
  - **Diretor_Id:** (chave-primária) identidicação dos diretores.
  - **id_osc:** (chave-estrangeira) identificação da OSC.
  - **url_principal:** URL do relatório circunstanciado.
  - **tp_sede:** Tipo de sede da entidade (Alugada; Cedida; Comodato;
    Outros;Propria).
  - **nm_cartorio:** Nome do cartório do registro legal da entidade.
  - **dt_reg:** Data do registro da entidade.
  - **in_mudanca_previa:** Indicador de mudança na diretoria no
    exercício anterior.
  - **dt_inicio_mandato_atual:** Data de início do mandato atual.
  - **dt_fim_mandato_atual:** Data de término do mandato atual.
  - **nm_diretor:** Nome do diretor.
  - **nm_ocupacao:** Nome do cargo do diretor.
  - **nm_genero:** Nome do gênero do diretor.
  - **in_empregado_publico:** Indicador de que o diretor é funcionário
    público.
  - **in_funcao_remunerada:** Indicador de que o diretor exerce função
    remunerada na entidade.
  - **nm_funcao_remunerada:** Nome da função remunerada exercida na
    entidade. <br><br>
- Tabela **VinculosEmpregaticiosAno:**
  - **id_osc:** (chave-primária, chave-extrangeira) identificação da
    OSC.
  - **Ano:** (chave-primária)
  - **n_vinc_ativos:**
  - **n_vinc_defic:**

### Formatação dos dados originais no novo *schema*

Finalizado a definição do modelo de dados, vamos pegar as [bases
originais](https://mapaosc.ipea.gov.br/base-dados) e colocar no novo
formato usando o R. Abaixo está um pequeno exemplo de como isso seria
feito. Fizemos a formatação dos dados das OSC, dos Governos (as bases
das UFs e dos Município já estavam previamente inseridas nos nossos
dados, através de dados baixados do IBGE), das áreas e subáreas de
atuação das OSC. A nossa proposta é continuar esse trabalho com todos os
dados do Mapa das OSC.

o script R descrito abaixo é o arquivo
[‘src/FormataBD.R’](src/FormataBD.R) deste repositório.

Primeiramente, vamos carregar alguns pacotes básicos de sobrevivência:

``` r
# Main packages
library(tidyverse)
library(data.table)
library(stringr)
library(assertthat)


# Options
options(stringsAsFactors = FALSE)
options(encoding = "utf-8")
options(dplyr.summarise.inform = FALSE)
```

Agora iremos criar a tabela **Governos**. Faremos isso empilhando as
chaves primárias dos municípios e dos Estados e atribuindo corretamente
a variável *Governo_Tipo*:

``` r
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
```

Agora iremos criar a tabela **OSC**, usando a tabela
*area_subarea.xlsx*, disponível nas bases de dados do Mapa das OSC. A
lista das **OSC** aparece várias vezes no banco e futuramente seria
interessante fazer uma checagem para ver se os dados estão consistentes.

``` r
library(readxl)

area_subarea <- read_xlsx("data/raw/area_subarea.xlsx", 
                          sheet = "area_subarea")

OSC <- area_subarea %>% 
  select(1, cd_identificador_osc, tx_razao_social_osc, tx_nome_fantasia_osc,
         dt_fundacao_osc, cd_natureza_juridica_osc)

fwrite(OSC, "data/dataset/OSC.csv", sep = ";", dec = ",")

rm(OSC)
```
