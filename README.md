# psy8712-final
Final Project

## Research Preview
###  (1) The Purpose
The project aims to finding the existence of these relationships, confirming control variables and identifying the most suitable analytical models as a first step. Accordingly, this project explores an Ordinary Least Squares (OLS) model alongside various machine learning models to determine the actual relationships and find the most appropriate model. Additionally, a Shiny application has been developed to aid in comprehending the outcomes of this study.

**Research Questions**
- *Research Question 1: Does a significant relationship exist between IV and DV?*
- *Research Question 2: Which control variables can be included to ensure a more precise study?*
- *Research Question 3: Which model is the most suitable for conducting the research?*

**Research Overview**
- *Research 1 & 2: Descriptive statistic, Correlation, Regression, and Shinyapp*
- *Research 3: OLS model and machine learning models*

### (2) Data
To address the research questions, I utilized secondary data from the 'Human Capital Corporate Panel' (HCCP), which has been developed and made publicly available by the South Korean government. The use of this data was authorized under approval number 389003 from Statistics Korea. Specifically, for this study, I employed the most recent data from HCCP Wave 2 conducted in 2022. Here is the link for the website about HCCP [clicking this link](https://www.krivet.re.kr/eng/eu/eh/euDAADs.jsp)

### (3) Main Variables & Code
The below is main variables and their code in the data.

- **Job satisfaction (DV)**:W21Q26A, W21Q26B, W21Q26C
- **Clan culture (IV)**: W21Q25D, W21Q25E, W21Q25F
- **Gender**: W21DQ01
- **Marital status**: W21DQ03
- **Permanent employment**: W21Q28

## Research Results
### (1) Research Results 1 (for question 1 and 2)
- **File direction:** Research Results 1 in the RMD file and app in the shiny_final file
- **Order:** (1) RMD: Import and Cleaning Data > Run descriptive statistics > Make histograms > Correlation and Regression > Export rds file (for running shinyapp) (2) Shiny app: Importing data > Make options > Make input (user selection) and output 
- **Descriptive Statistics:** I employed descriptive statistics techniques to analyze the dataset, extracting key metrics such as the mean, mode, minimum, and maximum values for numerical variables (e.g., job satisfaction, clan culture) using the summary function. Additionally, I generated histograms and calculated skewness and kurtosis to assess the normal distribution of the data. Furthermore, I determined the frequency counts for categorical variables using sum functions.
- **Correlation & Regression:** I conducted correlation and regression analyses to validate the relationships and probabilities, employing the cor.test and lm functions. The findings indicate significant relationships, with independent variables significantly impacting dependent variables. Additionally, I added the scatter plot between IV and DV with the regression line.
- **Shiny App:** Finally, I developed a Shiny app to generate scatter plots with controlled variables (Gender, Maritual status, and Permanent employment), aimed at enhancing readers' comprehension of the data. [clicking this link](https://min9509.shinyapps.io/shiny_final/)
- **Interpretation:** Based on the descriptive statistics and histograms, both the independent and dependent variables exhibit normal distributions. Furthermore, significant correlations and regressions were observed, indicating a positive relationship (coefficient = .592, p-value < .00) and a strong likelihood (coefficient = .526,  p-value < .00). The shiny application highlighted instances where specific combinations (such as Female-single-permanent) were absent in the control variables, suggesting a need for greater consideration of these control variables.

### (2) Research Results 2 (for question 3)
- **File direction**: Research Results 2 in the R file
-  **Order:** Import data > Cleaning data > Make test variables > Run Test > Get R-square
- **Machine Learning:** To identify the optimal models, I conducted training on four different models: the OLS model, Elastic Net model, Random Forest model, and XGB model. Subsequently, I obtained their respective 10-fold cross-validation R squared values, as well as the final holdout cross-validation R squared value.
- **Interpretation:** According to the tests, the results between models varied slightly, with OLS Regression achieving the highest R-squared values for both cross-validated (CV) and holdout sets. This could be due to OLS Regression being a simpler linear model that might fit the data well if the underlying relationship is linear. 

## Reflection
- **Answer 1:** A significant, positive, and strong relationship is evident between the Clan culture and Job satisfaction. This association indicates that a one-unit difference in clan culture corresponds to a model-predicted difference of 0.526 in mean job satisfaction. Therefore, this hypothesis model is well-suited for conducting advanced studies.
- **Answer 2:** According to the specific combinations (such as Female-single-permanent) were absent in the control variables. Thus, I need to more consider new variables.
- **Answer 3:** The results across different models varied slightly. The Ordinary Least Squares (OLS) Regression and Elastic Net models both exhibited high R-squared values, indicating strong predictive power for the data. For the main research, I will chooes OLS model and  the Elastic Net model. 

## Web-based binder
Here is the web-based biner to democratize access to my analysis, promote reproducibility and collaboration, facilitate sharing and publishing.[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/min9509/psy8712-final.git/HEAD)