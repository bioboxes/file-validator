import tempfile
import gzip
import shutil
import nose.tools as nose

from pymonad.Either import Left, Right

def create_temp_file(contents, dir=None):
    _, path = tempfile.mkstemp(dir=dir)
    with open(path, "w") as f:
        f.write(contents)
    return path

def create_gzip_temp_file(contents):
    tmpdirPath = tempfile.mkdtemp()
    path = create_temp_file(contents, dir=tmpdirPath)
    gzip_path = path + ".gz"
    with open(path, 'rb') as f_in, gzip.open(gzip_path, 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)
    return gzip_path

def assert_successful(a):
    nose.assert_equal(a.__class__, Right)

def assert_failure(a):
    nose.assert_equal(a.__class__, Left)

def create_biobox_dict(args):
    return {"version" : "0.9.0", "arguments" : args }
