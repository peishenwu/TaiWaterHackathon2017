# TaiWaterHackathon2017

這個是參加2017/3/11於新竹的台灣自來水黑客松成果

為用shiny + R + Kmeans 做了全國各地區用水pattern，以各一級發佈區的工廠數、四大便利商店數、醫院數與做clustering，並且用Regression做了一個簡單的用水Prediction，對於偏差很大的地區可以在地圖上辨識出來


作品發佈的link
https://peishenwu.shinyapps.io/test/

### kmeans clustering的說明

cluster|factory_count|store_count|school_count|hospital_count|判讀
:---:|:---:|:---:|:---:|:---:|:---:
1|3.60737758|0.1742474|-0.1194538|-0.117541236|工廠區
2|11.59650903|5.6571798|-0.1194538|-0.117541236|工商混合
3|-0.11713425 |  1.9572694   |-0.1194538   | 0.061163915| 商業區
4| 0.04298256 |  1.2895353 |   8.3706429   | 0.346578982| 校區
5|-0.16142780 | -0.3240460 |  -0.1194538   |-0.009639229| 綜合

```
Within cluster sum of squares by cluster:
[1]  918.0066 1948.9203 2838.4309 1367.5711 8465.8529
 (between_SS / total_SS =  63.1 %)
```

### 用水預測模型

_**predicted_water_usage ~ household_no + factory_count + school_count + hospital_count**_

目前只限定分析 201610、「一般用水」資料，以及該一級發佈區至少有一間便利商店(store_count>1)

會這樣設定是因為有許多地區是沒有active人口的(即便戶籍人口 <> 0)，故以便利商店作為marker去標定

### 模型結果
```
Call:
lm(formula = monthly_water_usage ~ household_no + factory_count + 
    school_count + hospital_count, data = .)

Residuals:
   Min     1Q Median     3Q    Max 
-56666  -1659   -160   1188  69196 

Coefficients:
                 Estimate Std. Error t value Pr(>|t|)    
(Intercept)     1.384e+03  2.590e+01   53.43   <2e-16 ***
household_no    2.272e+01  1.359e-01  167.18   <2e-16 ***
factory_count   1.914e+01  9.354e-01   20.46   <2e-16 ***
school_count    3.251e+03  1.614e+02   20.14   <2e-16 ***
hospital_count -2.675e-03  1.196e+02    0.00        1    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 3427 on 42068 degrees of freedom
Multiple R-squared:  0.4077,	Adjusted R-squared:  0.4076 
F-statistic:  7238 on 4 and 42068 DF,  p-value: < 2.2e-16
```
