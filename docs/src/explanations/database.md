``` @meta
CurrentModule = TaijaInteractive.DatasetsController
```


## Database Setup

The database is using `SearchLight` which runs locally on the users machine. Dashboards dashboardelements and wrappers for datasets and models are stored inside the database. These wrappers point to the files where the actual dataset and model files are stored. This is done using the `registerDatasetFromFile` and `registerModelFromFile` functions respectively. 