import tempfile
import nose.tools as nose

from pymonad.Either import Left, Right

def create_temp_file(contents):
    _, path = tempfile.mkstemp()
    with open(path, "w") as f:
        f.write(contents)
    return path

def assert_successful(a):
    nose.assert_equal(a.__class__, Right)

def assert_failure(a):
    nose.assert_equal(a.__class__, Left)
