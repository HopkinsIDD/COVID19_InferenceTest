
.PHONY: rerun rerun_simulations rerun_hospitalization clean_hospitalization clean clean_simulations

RSCRIPT=Rscript
PYTHON=python3
NCOREPER=1
PIPELINE=/home/jkaminsky/git/copies/COVIDScenarioPipeline/
CONFIG=config.yml

notebooks/minimal_20200429/minimal_20200429_report.html: .files/100_simulation_Influenza1918 .files/100_hospitalization_Influenza1918_med notebooks/minimal_20200429/minimal_20200429_report.Rmd
	$(RSCRIPT) -e 'rmarkdown::render("notebooks/minimal_20200429/minimal_20200429_report.Rmd"))'
notebooks/minimal_20200429/minimal_20200429_report.Rmd:
	mkdir -p notebooks/minimal_20200429
	$(RSCRIPT) -e 'rmarkdown::draft("$@",template="state_report",package="report.generation",edit=FALSE)'
.files/100_simulation_Influenza1918: .files/directory_exists 
	$(PYTHON) $(PIPELINE)/simulate.py -c $(CONFIG) -s Influenza1918 -n 100 -j $(NCOREPER)
	touch .files/100_simulation_Influenza1918
.files/100_hospitalization_Influenza1918_med: .files/directory_exists .files/100_simulation_Influenza1918
	$(RSCRIPT) $(PIPELINE)/R/scripts/hosp_run.R -s Influenza1918 -d med -j $(NCOREPER) -c $(CONFIG) -p $(PIPELINE)
	touch .files/100_hospitalization_Influenza1918_med

.files/directory_exists:
	mkdir .files
	touch .files/directory_exists


rerun: rerun_simulations rerun_hospitalization
rerun_filter:
	rm -f .files/1*_filter
rerun_importation:
	rm -f .files/1*_importation
rerun_simulations: clean_simulations
	rm -f .files/1*_simulation*
rerun_hospitalization:
	rm -f .files/1*_hospitalization*
clean: clean_simulations clean_hospitalization clean_reports
	rm -rf .files
clean_simulations: rerun_simulations
	rm -rf model_output
clean_hospitalization: rerun_hospitalization
	rm -rf hospitalization

clean_reports:
	rm -f notebooks/minimal_20200429/minimal_20200429_report.html