from bokeh.plotting import figure, output_file, show
import csv


with open('data1.csv', 'rb') as f:
    reader = csv.reader(f)

	#x = [1, 23, 33, 42, 52]
	#y = [6, 7, 8, 7, 3]
    x1=[]
    y1=[]
    x2=[]
    y2=[]
    x3=[]
    y3=[]
    x4=[]
    y4=[]

    for row in reader:
        x1.append(row[0])
        y1.append(row[1])
        x2.append(row[0])
        y2.append(row[2])
        #x3.append(row[0])
        #y3.append(row[3])
        #x4.append(row[0])
        #y4.append(row[4])
    print x1
    print y1


output_file("grafica.html")

p = figure(plot_width=500, plot_height=400)

# add both a line and circles on the same plot
p.line(x1, y1, line_width=2,legend="sin memoria compartida", line_color="blue")
p.circle(x1, y1, legend="sin memoria compartida",fill_color=None, line_color="red")
#p.circle(x1, y1, legend="sin(x)",fill_color="white", size=8,line_color="green")

p.line(x2, y2, line_width=2,legend="con memoria compartida, tile 70",line_color="orange")
p.square(x2, y2, legend="con memoria compartida, tile 70", fill_color=None, line_color="red")




p.legend.location = "bottom_right"
p.legend.background_fill_color = "white"
p.legend.background_fill_alpha = 0.5



show(p)
#save(p,"xx.html")
