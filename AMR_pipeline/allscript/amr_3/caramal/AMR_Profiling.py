#!/usr/bin/env python3
#-*- coding: utf-8 -*-
import re
import os
import sys
import argparse
from collections import defaultdict
import subprocess
import gzip
import datetime
from multiprocessing import Pool
import json
import codecs
from configparser import ConfigParser


# LIB_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
# sys.path.append(LIB_DIR)

if __name__ == '__main__':
    LIB_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    sys.path.append(LIB_DIR)
    from all_step import *
    
    args, basename = get_args_and_basename()  #解析输入文件 和文件basename
    Main(args, basename).run()  #类实例化

