# Validate Avro schemas
# Uses Apache Avro Python package

# Prerequisite:
# pip3 install avro-python3

import argparse
from avro import schema
import json

def validate_avro_schema(schema_str):
    try:
        parsed_schema = schema.Parse(schema_str)
        print("The schema is valid.")
        return True
    except schema.AvroException as e:
        print(f"The schema is invalid: {e}")
        return False

def read_schema_from_file(file_path):
    try:
        with open(file_path, 'r') as f:
            return f.read()
    except Exception as e:
        print(f"An error occurred while reading the file: {e}")
        return None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Validate an Avro schema.')
    parser.add_argument('file_path', type=str, help='Path to the Avro schema file')

    args = parser.parse_args()
    file_path = args.file_path
    
    schema_str = read_schema_from_file(file_path)
    if schema_str:
        validate_avro_schema(schema_str)
