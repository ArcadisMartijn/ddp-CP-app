library(shiny)
library(dplyr)
library(ggplot2)

make_basedf <- function(period, startValue, startYear){
    df <- data.frame(
        RYear = seq(0,period,1),
        Year = seq(startYear,startYear + period,1))
    df$residualDebt <- NA
    df$yearRedemption <- NA
    df$yearInterest <- NA
    df$yearPayment <- NA
    df[1,] <- c(0, startYear, startValue, 0, 0, 0)
    df
}

calcLinear <- function(df, interest){
    n <- nrow(df)-1
    B <- df[1,"residualDebt"]
    i <- interest / 100
    df$yearRedemption[-1] <- B / n
    df$residualDebt <- seq(B, 0, length.out = n + 1)
    df <- df %>%
        mutate(yearInterest = lag(residualDebt*(i))) %>%
        mutate(yearPayment = yearRedemption + yearInterest)
    df[is.na(df)] <- 0
    df
}

calcAnnuities <- function(df, interest){
    n <- nrow(df)-1
    B <- df[1,"residualDebt"]
    i <- interest / 100
    a <- i/(1-((1+i)^-n))*B
    df$yearPayment[-1] <- a
    df <- df %>% 
        mutate(residualDebt = (1+i)^RYear*B+(a/i)*(1-(1+i)^RYear)) %>%
        mutate(yearRedemption = lag(residualDebt) - residualDebt) %>%
        mutate(yearInterest = yearPayment - yearRedemption)
    df[is.na(df)] <- 0
    df
}


shinyServer(function(input, output) {

    output$plotDebt <- renderPlot({
        # Make dataframe
        df <- make_basedf(input$period, input$loan, input$year)
        if (input$type == "Linear"){
            df <- calcLinear(df, input$interest)
        }
        if (input$type == "Annuities"){
            df <- calcAnnuities(df, input$interest)
        }
        
        # Plot
        ggplot(df, aes(x = Year, y = residualDebt)) +
            geom_line(size = 1) +
            ggtitle("Developtment of debt") +
            ylab("Debt in entered currency") +
            xlab("Year")
    })
    
    output$plotPay <- renderPlot({
        # Make dataframe
        df <- make_basedf(input$period, input$loan, input$year)
        if (input$type == "Linear"){
            df <- calcLinear(df, input$interest)
        }
        if (input$type == "Annuities"){
            df <- calcAnnuities(df, input$interest)
        }
        
        # Plot
        ggplot(df[-1,], aes(x = Year, y = yearPayment)) + 
            geom_area(fill = "#3399FF") +
            geom_area(aes(y = yearRedemption), fill = "#00CC66") +
            scale_x_continuous(breaks = df$Year) +
            theme(axis.text.x = element_text(angle = 60, hjust = 1)) +
            ggtitle("Development of payment partition") +
            ylab("Payment in entered currency") +
            xlab("Year")
    })
    
    output$totalcost <- renderText({
        df <- make_basedf(input$period, input$loan, input$year)
        if (input$type == "Linear"){
            df <- calcLinear(df, input$interest)
        }
        if (input$type == "Annuities"){
            df <- calcAnnuities(df, input$interest)
        }
        paste("Total costs:", round(sum(df$yearPayment)),0)
    })
    
    output$partition <- renderText({
        df <- make_basedf(input$period, input$loan, input$year)
        if (input$type == "Linear"){
            df <- calcLinear(df, input$interest)
        }
        if (input$type == "Annuities"){
            df <- calcAnnuities(df, input$interest)
        }
        paste("Of which interest:", round(sum(df$yearInterest)),0)
    })
        
    output$table <- renderTable(df)
})
