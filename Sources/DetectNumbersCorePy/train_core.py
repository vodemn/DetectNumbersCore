from models.core import train

result = train(lr=0.08, first_layer_size=28, show_plot=False)
print("Prediction accuracy %.1f" % (result * 100))
