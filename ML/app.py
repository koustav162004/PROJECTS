import pandas as pd
import numpy as np
import pickle as pk
import streamlit as st
from sklearn.preprocessing import StandardScaler

# Load the model and scalers
model = pk.load(open('model.pkl', 'rb'))
scaler_x = pk.load(open('scaler_x.pkl', 'rb'))
scaler_y = pk.load(open('scaler_y.pkl', 'rb'))

st.header('Car Price Prediction ML Model')

# Load and preprocess the data
cars_data = pd.read_csv('cardata.csv')

def get_brand_name(car_name):
    car_name = car_name.split(' ')[0]
    return car_name.strip()

cars_data['name'] = cars_data['name'].apply(get_brand_name)

# User inputs
name = st.selectbox('Select Car Brand', cars_data['name'].unique())
year = st.slider('Car Manufactured Year', 1994, 2024)
km_driven = st.number_input('No of kms Driven', min_value=11, max_value=200000, value=1000)
fuel = st.selectbox('Fuel type', cars_data['fuel'].unique())
seller_type = st.selectbox('Seller type', cars_data['seller_type'].unique())
transmission = st.selectbox('Transmission type', cars_data['transmission'].unique())
owner = st.selectbox('Owner type', cars_data['owner'].unique())
mileage = st.number_input('Car Mileage', 10, 40)
engine = st.number_input('Engine CC', 700, 5000)
max_power = st.number_input('Max Power', 0, 200)
seats = st.slider('No of Seats', 2, 10)

if st.button("Predict"):
    input_data = pd.DataFrame(
        [[name, year, km_driven, fuel, seller_type, transmission, owner, mileage, engine, max_power, seats]],
        columns=['name', 'year', 'km_driven', 'fuel', 'seller_type', 'transmission', 'owner', 'mileage', 'engine', 'max_power', 'seats']
    )
    
    # Replace categorical values with numerical values
    input_data['owner'].replace(['First Owner', 'Second Owner', 'Third Owner',
                                 'Fourth & Above Owner', 'Test Drive Car'],
                                [1, 2, 3, 4, 5], inplace=True)
    input_data['fuel'].replace(['Diesel', 'Petrol', 'LPG', 'CNG'], [1, 2, 3, 4], inplace=True)
    input_data['seller_type'].replace(['Individual', 'Dealer', 'Trustmark Dealer'], [1, 2, 3], inplace=True)
    input_data['transmission'].replace(['Manual', 'Automatic'], [1, 2], inplace=True)
    input_data['name'].replace(['Maruti', 'Skoda', 'Honda', 'Hyundai', 'Toyota', 'Ford', 'Renault',
                                'Mahindra', 'Tata', 'Chevrolet', 'Datsun', 'Jeep', 'Mercedes-Benz',
                                'Mitsubishi', 'Audi', 'Volkswagen', 'BMW', 'Nissan', 'Lexus',
                                'Jaguar', 'Land', 'MG', 'Volvo', 'Daewoo', 'Kia', 'Fiat', 'Force',
                                'Ambassador', 'Ashok', 'Isuzu', 'Opel'],
                               list(range(1, 32)), inplace=True)
    
    # Calculate the 'no_year' feature
    input_data['no_year'] = 2024 - input_data['year']

    # Ensure the input data has the same columns as during training
    input_data = input_data[scaler_x.feature_names_in_]

    # Scale the input data
    input_data_scaled = scaler_x.transform(input_data)

    # Predict using the model
    prediction_scaled = model.predict(input_data_scaled)

    # Inverse transform the prediction to original scale
    prediction = scaler_y.inverse_transform(prediction_scaled.reshape(-1, 1))

    st.markdown(f'Predicted Car Price: {prediction[0][0]:.2f}')

# To run the app, save this script as app.py and run the command below in the terminal
# streamlit run app.py
