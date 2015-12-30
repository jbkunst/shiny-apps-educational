qs <- list()

qs$sols_per_pb_plot <- "
select camada, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Personal Banking'
group by camada, desc_path_sw"

qs$sols_per_cf_plot <- "
select camada, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Consumer Finance'
group by camada, desc_path_sw"

qs$ri_per_pb_plot <- "
select camada, risk_indicator, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Personal Banking'
group by camada, risk_indicator,  desc_path_sw"

qs$ri_per_cf_plot <- "
select camada, risk_indicator, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Consumer Finance'
group by camada, risk_indicator,  desc_path_sw"


qs$ressol_per_pb_plot <- "
select camada, resultado_sw, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Personal Banking'
group by camada, resultado_sw,  desc_path_sw"

qs$ressol_per_cf_plot <- "
select camada, resultado_sw, desc_path_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where desc_path_sw not in ('', 'Moroso', 'Renegociado') and segmento_label = 'Consumer Finance'
group by camada, resultado_sw,  desc_path_sw"
