import __init__
from init_project import *
#
from _utils.logger import get_logger
#
from time import time, sleep
from datetime import datetime
import pandas as pd
import csv
import os

logger = get_logger()

SLEEP_DURATION = 2
CLOCK_TIME_TH = 30 * 60


def run(processorID, num_workers=11):
    for i, fn in enumerate(os.listdir(dpath['stateBlockByMonth'])):
        if not fn.endswith('.csv'):
            continue
        if i % num_workers != processorID:
            continue
        process_file(fn)


def process_file(fn):
    logger.info('handle files; %s' % fn)
    ifpath = opath.join(dpath['stateBlockByMonth'], fn)
    oldTime = time()
    with open(ifpath, 'rb') as r_csvfile:
        reader = csv.reader(r_csvfile)
        header = reader.next()
        hid = {h: i for i, h in enumerate(header)}
        for row in reader:
            beginTime = eval(row[hid['beginTime']])
            clockTime = time()
            if clockTime - oldTime > CLOCK_TIME_TH:
                dt = datetime.fromtimestamp(beginTime)
                logger.info('handling %s d%02d h%02d m%02d' % (fn, dt.day, dt.hour, dt.minute))
            did = int(row[hid['did']])
            ofpath = opath.join(dpath['stateBlockByDriver'], 'stateBlockByDriver-%d.csv' % did)
            lock_fpath = opath.join(dpath['stateBlockByDriver'], '%d.lock' % did)
            if opath.exists(ofpath):
                append_row(ofpath, lock_fpath, row)
            else:
                create_csv(ofpath, lock_fpath, header, row)


def create_csv(ofpath, lock_fpath, header, row):
    try:
        f = open(lock_fpath, 'wt')
        with open(ofpath, 'wt') as w_csvfile:
            writer = csv.writer(w_csvfile, lineterminator='\n')
            writer.writerow(header)
            writer.writerow(row)
        f.close()
        os.remove(lock_fpath)
    except OSError:
        create_csv(ofpath, lock_fpath, header, row)


def append_row(ofpath, lock_fpath, row):
    try:
        while opath.exists(lock_fpath):
            sleep(SLEEP_DURATION)
        f = open(lock_fpath, 'wt')
        with open(ofpath, 'a') as w_csvfile:
            writer = csv.writer(w_csvfile, lineterminator='\n')
            writer.writerow(row)
        f.close()
        os.remove(lock_fpath)
    except OSError:
        append_row(ofpath, lock_fpath, row)


def arrange_files(processorID, num_workers=11):
    for i, fn in enumerate(os.listdir(dpath['stateBlockByDriver'])):
        if not fn.endswith('.csv'):
            continue
        if i % num_workers != processorID:
            continue
        _, _did = fn[:-len('.csv')].split('-')
        if len(_did.split()) == 2:
            did = int(_did.split()[0])
            ifpath1 = opath.join(dpath['stateBlockByDriver'], 'stateBlockByDriver-%d.csv' % did)
            ifpath2 = opath.join(dpath['stateBlockByDriver'], fn)
            ipaths = [ifpath1, ifpath2]
            df1, df2 = map(pd.read_csv, ipaths)
            df = df1.append(df2)
        else:
            did = int(_did)
            ifpath = opath.join(dpath['stateBlockByDriver'], fn)
            df = pd.read_csv(ifpath)
        ofpath = opath.join(dpath['arranged'], 'stateBlockByDriver-%d.csv' % did)
        df = df.sort_values(['beginTime'], ascending=[True])
        df = df.drop_duplicates()
        df.to_csv(ofpath, index=False)


if __name__ == '__main__':
    arrange_files(0)
    pass
    # run(0)
