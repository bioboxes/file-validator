import argparse
import encodings

def get_arguments():
    parser = argparse.ArgumentParser(description='Validates the input data for a biobox.')
    parser.add_argument('--schema',  '-s', dest='schema_file',    required=True)
    parser.add_argument('--input',   '-i', dest='threshold_file', required=True)
    return vars(parser.parse_args())

def run():
    get_arguments()
