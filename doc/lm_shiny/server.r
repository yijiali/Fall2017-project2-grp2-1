rm(list=ls())
setwd('/Users/syasuda/Downloads/Fall2017-project2-grp2/Fall2017-project2-grp2')

# install & load necessary packages
packages.used=c("shiny","readxl","ggplot2")
packages.needed=setdiff(packages.used, intersect(installed.packages()[,1], packages.used))
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE,repos='http://cran.us.r-project.org')
}
library(shiny)
library(readxl)
library(ggplot2)
#runExample("01_hello")


### Load sheets from the raw data
achievements <- read_excel("./data/2014_2015_HS_SQR_Results_2016_01_07.xlsx", 
                                                   sheet = "Student Achievement",skip=1)
framework <- read_excel("./data/2014_2015_HS_SQR_Results_2016_01_07.xlsx", 
                                                   sheet = "Framework",skip=1)

### Clean up the data
# Create df per category and rename columns so that it's easy to refer to.
# For column names, C in C1, C2... stands for categorical value. N for numerical value.

rigorous.col = c("School Name", "Rigorous Instruction - Element Score",
                  "Percentage of students who say that they learn a lot from feedback on their work",
                  "Percentage of students who know what their teacher wants them to learn in class",
                  "Percentage of teachers who say that students build on each others' ideas during class discussions")
rigorous.df = framework[rigorous.col]
rigorous.col.short = c("SchoolName","Score","N1","N2","N3")
colnames(rigorous.df) = rigorous.col.short
names(rigorous.col) = rigorous.col.short #rigorous.col[['C1']] to refer to the name


teachers.col = c("School Name","Collaborative Teachers - Element Score",
                      "Percentage of teachers who say that they work together to design instructional programs",
                      "Percentage of teachers who say that they have opportunities to work productively with colleagues in their school",
                      "Percentage of teachers who say that they feel responsible that all students learn")
teachers.df = framework[teachers.col]
teachers.col.short = c("SchoolName","Score","N1","N2","N3")
colnames(teachers.df) = teachers.col.short
names(teachers.col) = teachers.col.short


supportive.col = c("School Name","Supportive Environment - Element Score",
                   "Percentage of students who feel safe in the hallways, bathrooms, locker room, and cafeteria",
                   "Percentage of students who say that teachers notice when they are upset or having emotional difficulty",
                   "Percentage of students who say that this school supports students in navigating the post-secondary process")
supportive.df = framework[supportive.col]
supportive.col.short = c("SchoolName","Score","N1","N2","N3")
colnames(supportive.df) = supportive.col.short
names(supportive.col) = supportive.col.short


leadership.col = c("School Name", "Effective School Leadership - Element Score",
                   "Percentage of teachers who say that the principal communicates a clear vision for this school",
                   "Percentage of teachers who say that curriculum and instruction are well coordinated across different grade levels",
                   "Percentage of parents who feel that the principal works to create a sense of community in the school")
leadership.df = framework[leadership.col]
leadership.col.short = c("SchoolName","Score","N1","N2","N3")
colnames(leadership.df) = leadership.col.short
names(leadership.col) = leadership.col.short


community.col = c("School Name","Strong Family-Community Ties - Element Score",
                  "Percentage of parents who say that school staff regularly communicate with them about how the staff can help their children learn",
                  "Percentage of parents who feel that teachers try to understand families' problems and concerns",
                  "Percentage of teachers who say that teachers at this school work closely with families to meet students' needs")
community.df = framework[community.col]
community.col.short = c("SchoolName","Score","N1","N2","N3")
colnames(community.df) = community.col.short
names(community.col) = community.col.short

trust.col = c("School Name","Trust - Element Score",
              "Percentage of teachers who say they trust the principal",
              "Percentage of teachers who say that they trust each other",
              "Percentage of parents who say that school staff work hard to build trusting relationships with them",
              "Percentage of students who say that teachers treat them with respect")
trust.df = framework[trust.col]
trust.col.short = c("SchoolName","Score","N1","N2","N3","N4")
colnames(trust.df) = trust.col.short
names(trust.col) = trust.col.short

achievements.col = c("School Name","Metric Value - Graduation Rate, 4 year",
                     "Metric Value - Postsecondary Enrollment Rate, 6 months After High School")
achievements = achievements[achievements.col]
achievements = na.omit(achievements)
colnames(achievements) = c("SchoolName","Graduate_Pct",
                                 "Postsecondary_Enrollment_Pct")

rigorous.df <- merge(x = achievements, y = rigorous.df, by = "SchoolName", all.x = TRUE)
teachers.df <- merge(x = achievements, y = teachers.df, by = "SchoolName", all.x = TRUE)
supportive.df <- merge(x = achievements, y = supportive.df, by = "SchoolName", all.x = TRUE)
leadership.df <- merge(x = achievements, y = leadership.df, by = "SchoolName", all.x = TRUE)
community.df <- merge(x = achievements, y = community.df, by = "SchoolName", all.x = TRUE)
trust.df <- merge(x = achievements, y = trust.df, by = "SchoolName", all.x = TRUE)


#######################
### Server
#######################
shinyServer(function(input, output) {
  df.list = list(rigorous.df,teachers.df,supportive.df,
                 leadership.df,community.df,trust.df)
  names(df.list)= 1:6
  
  output$lmPlot <- renderPlot({
    
    load.plot = function(df, x, y) {
      ggplot(subset(df, !is.na(df)), aes_string(x=x, y=y)) + 
        geom_point(shape=1,na.rm=TRUE) +
        geom_smooth(method=lm,na.rm=TRUE)
    }
    
    df = df.list[[input$x1]]
    y_string= input$y
    if(input$x1==1){
      x_string = colnames(df[as.numeric(input$x21)+3])
    }
    else if(input$x1==2){
      x_string = colnames(df[as.numeric(input$x22)+3])
    }
    else if(input$x1==3){
      x_string = colnames(df[as.numeric(input$x23)+3])
    }
    else if(input$x1==4){
      x_string = colnames(df[as.numeric(input$x24)+3])
    }
    else if(input$x1==5){
      x_string = colnames(df[as.numeric(input$x25)+3])
    }
    else if(input$x1==6){
      x_string = colnames(df[as.numeric(input$x26)+3])
    }

    set.seed(123)
    load.plot(df,x_string,y_string)
    
  })
  
  output$summary <- renderPrint({ 
    df = df.list[[input$x1]]
    y_string= input$y
    if(input$x1==1){
      x_string = colnames(df[as.numeric(input$x21)+3])
    }
    else if(input$x1==2){
      x_string = colnames(df[as.numeric(input$x22)+3])
    }
    else if(input$x1==3){
      x_string = colnames(df[as.numeric(input$x23)+3])
    }
    else if(input$x1==4){
      x_string = colnames(df[as.numeric(input$x24)+3])
    }
    else if(input$x1==5){
      x_string = colnames(df[as.numeric(input$x25)+3])
    }
    else if(input$x1==6){
      x_string = colnames(df[as.numeric(input$x26)+3])
    }
    
    formula <- paste(y_string, "~", x_string)
    fit = lm(formula, data=df, na.action = na.exclude)
    summary(fit)
    #summary(fit)$coefficients
  })
  
})
