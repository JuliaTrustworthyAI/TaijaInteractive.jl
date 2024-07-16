## Software Architecture

The diagram below provides an overview of the package architecture. It is built around five core modules: 1) `Dashboards` is concerned with the management of dashboards; 2) `DashboardElements` is used to maintain the different elements displayed on the board such as daatset-explanations or counterfactal-plots;[1] 3) `Datasets` manages the storage and manipulation of datasets; 4) `HuggingFaceController` is responsible for establishing a connection with the HUggingface API; 5) `Models` is concerned with the management of models.




[1] We have made an effort to keep the code base a flexible and extensible as possible, you can add moretypes of dashboard-elements refer to how-to