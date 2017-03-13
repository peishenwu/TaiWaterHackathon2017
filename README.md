# TaiWaterHackathon2017

這個是參加2017/3/11於新竹的台灣自來水黑客松成果

為用shiny + R + Kmeans 做了全國各地區用水pattern 以各一級發佈區的工廠數、四大便利商店數、醫院數，先做clustering得到各種不同的「區位」，並且用Regression以上述的變項，配合人口做了一個簡單的用水Prediction，對於實際用水與預測用水差異很大的地區，可以在地圖上辨識出來做後續分析

作品發佈的link (點擊進來玩玩看！)
https://peishenwu.shinyapps.io/test/

### 怎麼玩？
1. 點擊上面的link之後，在搜尋區域搜尋排名在41名以後的地區，cluster選擇5 (綜合區域)，其中我們來看「宜蘭縣 五結鄉	孝威村」
![alt text](https://github.com/peishenwu/TaiWaterHackathon2017/blob/master/tutorial_img/01.png)

2. 可以在地圖上點擊該節點，他的實際耗水量是我們模型預期的3.578倍
![alt text](https://github.com/peishenwu/TaiWaterHackathon2017/blob/master/tutorial_img/02.png)

3. 我們在表格右上的文字匡內輸入「宜蘭」，可以看到含**宜蘭**的表格結果
![alt text](https://github.com/peishenwu/TaiWaterHackathon2017/blob/master/tutorial_img/03.png)

4. 可以看到在cluster5裡，宜蘭地區耗水實際跟預期差距最大的前三名為「孝威村」「協和」「東門」
![alt text](https://github.com/peishenwu/TaiWaterHackathon2017/blob/master/tutorial_img/04.png)

5. 用google map街景實際去看，原來是民宿區啊，而且還有一個人工湖？ 或許可以解釋？
![alt text](https://github.com/peishenwu/TaiWaterHackathon2017/blob/master/tutorial_img/05.png)

### 這次用到的資料集
1. 中華民國最小統計區資料 [https://sheethub.com/area.reference.tw/]
2. 各縣統計區人口統計 最小統計區 [http://segis.moi.gov.tw/]
3. 一級發佈區的每月用水資料 [http://www.water.gov.tw/ct.aspx?xItem=153656&CtNode=3395&mp=1]
4. 登記工廠名錄 [http://data.gov.tw/node/6569]
5. 健保局特約醫療院所 (http://www.nhi.gov.tw/webdata/webdata.aspx?menu=18&menu_id=683&webdata_id=660&WD_ID=755)
6. 大專校院名錄 [http://data.gov.tw/node/6091]
7. 全國營業(稅籍)登記資料集 [http://data.gov.tw/node/9400]

### kmeans clustering的說明

cluster|factory_count|store_count|school_count|hospital_count|判讀
:---:|:---:|:---:|:---:|:---:|:---:
1|**3.60737758**|0.1742474|-0.1194538|-0.117541236|工廠區
2|**11.59650903**|**5.6571798**|-0.1194538|-0.117541236|工商混合
3|-0.11713425 |  **1.9572694**   |-0.1194538   | 0.061163915| 商業區
4| 0.04298256 |  1.2895353 |   **8.3706429**   | 0.346578982| 校區
5|-0.16142780 | -0.3240460 |  -0.1194538   |-0.009639229| 綜合

```
Within cluster sum of squares by cluster:
[1]  918.0066 1948.9203 2838.4309 1367.5711 8465.8529
 (between_SS / total_SS =  63.1 %)
```

### 用水預測模型

_**predicted_water_usage ~ household_no + factory_count + school_count + hospital_count**_

目前只限定分析 201610、「一般用水」資料，以及該一級發佈區至少有一間便利商店(store_count>1)

會這樣設定是因為有許多地區實際的人口是被高估的(戶籍人口小，但是在那邊活動的人口多，例如觀光區)

而便利商店具有分佈廣、服務半徑小的特點，我們認為可以代表該地區「實際活躍的人口數」，所以我們以每個一級發佈區裡便利商店的數量，作為除了戶籍人口外，另一個可以預測用水的變項

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


