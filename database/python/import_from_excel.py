import pymysql
import pandas as pd
import random
import os
from dotenv import load_dotenv

load_dotenv()

# Connexion à MySQL avec les variables d'environnement
connection = pymysql.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

# Charger le fichier Excel
file_path = "database/python/liste.xlsx"
df = pd.read_excel(file_path, engine="openpyxl")

# Affichage des colonnes pour vérifier leur existence
print(df.columns)

# Assurer que les colonnes nécessaires existent dans le DataFrame
if "DURUMU" not in df.columns or "TEL N° FR" not in df.columns or "TEL N° TR" not in df.columns:
    print("⚠️ Colonne manquante dans le fichier Excel")
    connection.close()
    exit()

# Traitement des données
df["Statut"] = df["DURUMU"].map(lambda x: "Aktif" if x == "U" else "Donduruldu")
df["Telephone"] = df.apply(
    lambda row: f"+33{str(row['TEL N° FR']).replace(' ', '')[1:]}" if pd.notna(row["TEL N° FR"]) 
    else f"+90{str(row['TEL N° TR']).replace(' ', '')[1:]}" if pd.notna(row["TEL N° TR"]) else None, 
    axis=1
)

import random

df["CodeBarre"] = df.apply(lambda x: random.randint(100000000000, 999999999999), axis=1)

# Sélection des colonnes importantes
df = df[["SOYADI", "ADI", "Telephone", "Statut", "CodeBarre"]]

# Remplacement des valeurs NaN par None
df = df.where(pd.notna(df), None)

# Affichage pour vérifier les données
print(df.head())

# Insertion des données dans la base de données
with connection.cursor() as cursor:
    for _, row in df.iterrows():
        sql = """
        INSERT INTO Membre (nom, prenom, telephone, statut, barcode, cenazeFonu)
        VALUES (%s, %s, %s, %s, %s, true)
        """
        try:
            cursor.execute(sql, (row["SOYADI"], row["ADI"], row["Telephone"], row["Statut"], row["CodeBarre"]))
        except Exception as e:
            print(f"⚠️ Erreur lors de l'insertion de {row}: {e}")

    connection.commit()

connection.close()
print("✅ Insertion terminée !")