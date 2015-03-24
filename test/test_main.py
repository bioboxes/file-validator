import helper              as f
import nose.tools          as nose
import validate_input.main as main

from pymonad.Either import Left, Right

def test_loading_valid_yaml():
    file_  = f.create_temp_file("---\n- valid yaml")
    result = main.parse_yaml(file_)
    f.assert_successful(result)
    nose.assert_equal(result.getValue(), ["valid yaml"])

def test_loading_invalid_yaml():
    file_  = f.create_temp_file("'invalid yaml")
    result = main.parse_yaml(file_)
    f.assert_failure(result)

def test_generate_exit_status():
    nose.assert_equal(main.generate_exit_status(Left("msg")),  (1, "msg"))
    nose.assert_equal(main.generate_exit_status(Right("msg")), (0, "msg"))
