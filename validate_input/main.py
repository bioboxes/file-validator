import argparse
import encodings
import yaml
import yaml.scanner as scan

from pymonad.Either import Left, Right
from pymonad.Reader import curry

# This imports the * and & operators for monads
from pymonad.Applicative import *

def generate_exit_status(result):
    is_error = (result.__class__ == Left)
    exit_code = 1 if is_error else 0
    return (exit_code, result.getValue())

def get_arguments():
    parser = argparse.ArgumentParser(description='Validates the input data for a biobox.')
    parser.add_argument('--schema', '-s', dest='schema_file', required=True)
    parser.add_argument('--input',  '-i', dest='input_file',  required=True)
    return vars(parser.parse_args())

def parse_yaml(file_):
    try:
        with open(file_, "r") as f:
            return Right(yaml.load(f.read()))
    except scan.ScannerError:
        return Left("Error parsing the YAML file: {0}".format(file_))

@curry
def validate(schema, input_):
    # Not implemented yet. The json schema code for comparing two dicts goes here
    None

def run():
    args   = get_arguments()
    result = validate * parse_yaml(args['schema_file']) & parse_yaml(args['input_file'])
    return generate_exit_status(result)
