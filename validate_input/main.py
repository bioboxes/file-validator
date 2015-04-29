import argparse
import yaml
import yaml.scanner as scan
import os.path
from jsonschema import Draft4Validator
from jsonschema.exceptions import best_match
from pymonad.Either import Left, Right
from pymonad.Reader import curry

# This imports the * and & operators for monads
from pymonad.Applicative import *


def generate_exit_status(result):
    is_error = (result.__class__ == Left)
    if is_error:
        return (1, result.getValue() + "\n")
    else:
        return (0, "")

def get_arguments():
    parser = argparse.ArgumentParser(
            description='Validates the input data for a biobox.')
    parser.add_argument('--schema', '-s', dest='schema_file', required=True)
    parser.add_argument('--input',  '-i', dest='input_file',  required=True)
    return vars(parser.parse_args())

def parse_yaml(file_):
    try:
        with open(file_, "r") as f:
            return Right(yaml.load(f.read()))
    except scan.ScannerError:
        return Left("Error parsing the YAML file: {0}".format(file_))
    except IOError:
        return Left("File not found: {0}".format(file_))

@curry
def validate(schema, input_):
    validator = Draft4Validator(schema)
    if(validator.is_valid(input_)):
        return Right(input_)
    else:
        error = best_match(Draft4Validator(schema).iter_errors(input_))
        return Left(error.message)

def check_mounted_files(input_):
    files = filter(lambda x : x.iterkeys().next() in get_file_types(), input_["arguments"])
    for file in files:
        file = file.itervalues().next()
        if not os.path.isfile(file[0]["value"]):
            return Left("Provided path " + file[0]["value"] + " of item " + file[0]["id"] + " does not exist.")
    return Right(input_)

def get_file_types():
    return ["fastq"]

def run():
    args  = get_arguments()
    chain = [validate,
             parse_yaml(args['schema_file']),
             parse_yaml(args['input_file'])]

    result = reduce(lambda method, result: result >> method, chain) >> check_mounted_files

    return generate_exit_status(result)
