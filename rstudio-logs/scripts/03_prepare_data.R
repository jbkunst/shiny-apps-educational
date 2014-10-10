source("00_parameters_and_packages.R")

db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))

# dbGetQuery(conn = db, statement =  "select count(*) as nrows, sum(n) as nrows_original from rstudio_logs_aux")
# dbGetQuery(conn = db, statement =  "select * from rstudio_logs_aux limit 10")
# dbGetQuery(conn = db, statement =  "select *, date(timestamp, 'unixepoch', 'localtime') as date from rstudio_logs_aux limit 10 ")

try(dbRemoveTable(conn = db, name = "rstudio_logs"))
dbSendQuery(conn = db, statement = "create table rstudio_logs as select timestamp, package, country, sum(n) as n from rstudio_logs_aux group by timestamp, package, country")

# dbGetQuery(conn = db, statement =  "select count(*) as nrows, sum(n) as nrows_original from rstudio_logs_aux")
# dbGetQuery(conn = db, statement =  "select count(*) as nrows, sum(n) as nrows_original from rstudio_logs")

try(dbRemoveTable(conn = db, name = "rstudio_logs_aux"))

# dbGetQuery(conn = db, statement =  "select *, date(timestamp, 'unixepoch', 'localtime') as date from rstudio_logs limit 10 ")
# dbGetQuery(conn = db, statement =  "select min(timestamp), max(timestamp) from rstudio_logs limit 10 ")
# dbGetQuery(conn = db, statement =  "select * from rstudio_logs where timestamp < 1409112000 and timestamp > 1409000000")

dbSendQuery(conn =  db, statement = "create index ts on rstudio_logs (timestamp)")


# dbGetQuery(conn = db, statement =  "select *, date(timestamp, 'unixepoch', 'localtime') as date from rstudio_logs limit 10 ")
# dbGetQuery(conn = db, statement =  "select count(*) as nrows, sum(n) as nrows_original from rstudio_logs")
# dbGetQuery(conn = db, statement =  "select * from rstudio_logs where timestamp < 1409112000 and timestamp > 1409000000")