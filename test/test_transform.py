import unittest

import pandas.api.types as ptypes
from etl.modules import transform


class TestTransform(unittest.TestCase):
    def test_clean_csv(self):
        t = transform.clean_csv('test/test-data.csv')

        assert ptypes.is_datetime64_dtype(t['date'])
        assert ptypes.is_integer_dtype(t['cases'])
        assert ptypes.is_integer_dtype(t['deaths'])
