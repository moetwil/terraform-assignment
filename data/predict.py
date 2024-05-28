import argparse
import pandas as pd
import joblib

def load_model(model_path):
    return joblib.load(model_path)

def make_prediction(model, data):
    df = pd.DataFrame([data])
    prediction = model.predict(df)
    return prediction[0]

def main():
    parser = argparse.ArgumentParser(description='Predict house price based on features.')
    parser.add_argument('--longitude', type=float, required=True, help='Longitude of the location')
    parser.add_argument('--latitude', type=float, required=True, help='Latitude of the location')
    parser.add_argument('--housing_median_age', type=int, required=True, help='Median age of the houses')
    parser.add_argument('--total_rooms', type=int, required=True, help='Total number of rooms')
    parser.add_argument('--total_bedrooms', type=int, required=True, help='Total number of bedrooms')
    parser.add_argument('--population', type=int, required=True, help='Population of the area')
    parser.add_argument('--households', type=int, required=True, help='Number of households')
    parser.add_argument('--median_income', type=float, required=True, help='Median income of the area')

    args = parser.parse_args()

    model = load_model('housing_rf.pkl')

    data = {
        'longitude': args.longitude,
        'latitude': args.latitude,
        'housing_median_age': args.housing_median_age,
        'total_rooms': args.total_rooms,
        'total_bedrooms': args.total_bedrooms,
        'population': args.population,
        'households': args.households,
        'median_income': args.median_income
    }

    prediction = make_prediction(model, data)
    print(f'Predicted house price: {prediction}')

if __name__ == '__main__':
    main()
