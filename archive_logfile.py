#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
Filename: archive_logfile.py
Description: archive logfile using gnu gzip
"""
import os
import sys
import re
import gzip
import argparse

def size_human2byte(s_str):#{{{
    """Convert human readable size into bytes in integer"""
    s_byte = None
    if s_str.isdigit():
        s_byte = int(s_str)
    else:
        s_str = s_str.upper()
        match = re.match(r"([0-9]+)([A-Z]+)", s_str, re.I)
        if match:
            items = match.groups()
            size = int(items[0])
            if items[1] in ["B"]:
                s_byte = size
            elif items[1] in ["K", "KB"]:
                s_byte = size*1024
            elif items[1] in ["M", "MB"]:
                s_byte = size*1024*1024
            elif items[1] in ["G", "GB"]:
                s_byte = size*1024*1024*1024
            else:
                print("Bad maxsize argument:", s_str, file=sys.stderr)
                return -1
        else:
            print("Bad maxsize argument:", s_str, file=sys.stderr)
            return -1
    return s_byte

#}}}
def archive_file(filename, maxsize):#{{{
    """
    Archive the logfile if its size exceeds the limit
    """
    if not os.path.exists(filename):
        print(filename, "does not exist. ignore.", file=sys.stderr)
        return 1

    filesize = os.path.getsize(filename)
    if filesize > maxsize:
        cnt = 0
        zipfile = ""
        while 1:
            cnt += 1
            zipfile = "%s.%d.gz"%(filename, cnt)
            if not os.path.exists(zipfile):
                break
        # write zip file
        try:
            f_in = open(filename, 'rb')
        except IOError:
            print("Failed to read %s"%(filename), file=sys.stderr)
            return 1
        try:
            f_out = gzip.open(zipfile, 'wb')
        except IOError:
            print("Failed to write to %s"%(zipfile), file=sys.stderr)
            return 1

        f_out.writelines(f_in)
        f_out.close()
        f_in.close()
        print("%s is archived to %s"%(filename, zipfile))
        os.remove(filename)
    return 0
#}}}
def main(g_params):#{{{
    """main procedure"""
    parser = argparse.ArgumentParser(
        description='Archive (gzip) the logfile if its size is over the threshold',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''\
Created 2014-05-22, updated 2022-02-11, Nanjiang Shu
''')
    parser.add_argument('file_list', metavar='FILE', nargs='*',
                        help='supply one or more files')
    parser.add_argument('-l', metavar='LISTFILE', dest='file_list_file',
                        help='provide a file with a list of filenames')
    parser.add_argument('-maxsize', metavar='SIZE', dest='max_size',
                        help='Set the threshold of the filesize (default: 20Mb),\
                                e.g. 500k, 20M, 500000b, 5000, 1G')

    args = parser.parse_args()

    file_list = args.file_list
    file_list_file = args.file_list_file
    maxsize_str = args.max_size

    if not maxsize_str is None:
        maxsize = size_human2byte(maxsize_str)
        if maxsize > 0:
            g_params['maxsize'] = maxsize
        else:
            return 1

    if not file_list_file is None:
        tmplist = open(file_list_file, "r").read().split('\n')
        tmplist = [x.strip() for x in tmplist]
        file_list += tmplist

    if not file_list:
        print("No input file is set. exit.", file=sys.stderr)
    for fname in file_list:
        archive_file(fname, g_params['maxsize'])

    return 0
# }}}

def init_global_param():#{{{
    """Init global parameters"""
    g_params = {}
    g_params['isQuiet'] = True
    g_params['maxsize'] = 20*1024*1024
    return g_params
#}}}
if __name__ == '__main__':
    sys.exit(main(init_global_param()))
