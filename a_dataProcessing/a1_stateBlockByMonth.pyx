import __init__
from init_project import *
#
from _utils.logger import get_logger
#
from time import time
from datetime import datetime
import csv

logger = get_logger()

log_postfixs = ['-normal.csv', '-outside.csv', '-special.csv', '-unknown.csv']
MIN20 = 20 * 60
CLOCK_TIME_TH = 30 * 60


def run(yymm):
    logger.info('handle files; %s' % yymm)
    ofpath = opath.join(dpath['stateBlockByMonth'], 'stateBlockByMonth-%s.csv' % yymm)
    yy, mm = yymm[:2], yymm[2:]
    yyyy = '20%s' % yy
    log_dir = opath.join(TAXI_HOME, '%s/%s/logs' % (yyyy, mm))
    if not opath.exists(log_dir):
        logger.info('No data about %s' % yymm)
        return None
    #
    with open(ofpath, 'wt') as w_csvfile:
        writer = csv.writer(w_csvfile, lineterminator='\n')
        header = ['did', 'state',
                  'beginTime', 'beginLon', 'beginLat',
                  'endTime', 'endLon', 'endLat',
                  'duration']
        writer.writerow(header)
    log_fpaths = [opath.join(log_dir, 'logs-%s%s' % (yymm, postfix)) for postfix in log_postfixs]
    csvReaders = {i: csv.reader(open(fpath, 'rb')) for i, fpath in enumerate(log_fpaths)}
    header = None
    for reader in csvReaders.itervalues():
        header = reader.next()
    hid = {h: i for i, h in enumerate(header)}
    rows = {i: reader.next() for i, reader in csvReaders.iteritems()}
    vid_stateBlock = {}
    oldTime = time()
    while csvReaders:
        minT, minID = 1e400, -1
        for i, row in rows.iteritems():
            t = eval(row[hid['time']])
            if t < minT:
                minT, minID = t, i
        minT_row = rows[minID]
        t = eval(minT_row[hid['time']])
        clockTime = time()
        if clockTime - oldTime > CLOCK_TIME_TH:
            dt = datetime.fromtimestamp(t)
            logger.info('handling %s y%d m%02d h%02d m%02d' % (yymm, dt.year, dt.month, dt.hour, dt.minute))
            oldTime = clockTime
        assert t == minT
        vid, did, state = map(int, [minT_row[hid[cn]] for cn in ['vehicle-id', 'driver-id', 'state']])
        lon, lat = map(eval, [minT_row[hid[cn]] for cn in ['longitude', 'latitude']])
        if did == -1:
            lookup_next_row(minID, rows, csvReaders)
            continue
        #
        if not vid_stateBlock.has_key(vid):
            vid_stateBlock[vid] = stateBlock(did, state, t, lon, lat)
        else:
            sb = vid_stateBlock[vid]
            if state == sb.state:
                if t - sb.endTime > MIN20:
                    write_prevStateBlock(sb, ofpath)
                    vid_stateBlock[vid] = stateBlock(did, state, t, lon, lat)
                else:
                    sb.endTime, sb.endLon, sb.endLat = t, lon, lat
            else:
                write_prevStateBlock(sb, ofpath)
                vid_stateBlock[vid] = stateBlock(did, state, t, lon, lat)
        lookup_next_row(minID, rows, csvReaders)
    #
    for sb in vid_stateBlock.itervalues():
        write_prevStateBlock(sb, ofpath)


def lookup_next_row(minID, rows, csvReaders):
    try:
        rows[minID] = csvReaders[minID].next()
    except StopIteration:
        csvReaders.pop(minID)
        rows.pop(minID)


def write_prevStateBlock(sb, ofpath):
    with open(ofpath, 'a') as w_csvfile:
        writer = csv.writer(w_csvfile, lineterminator='\n')
        writer.writerow([sb.did, sb.state,
                         sb.beginTime, sb.beginLon, sb.beginLat,
                         sb.endTime, sb.endLon, sb.endLat,
                         sb.endTime - sb.beginTime])

class stateBlock(object):
    def __init__(self, did, state, t, lon, lat):
        self.did, self.state = did, state
        #
        self.beginTime, self.beginLon, self.beginLat = t, lon, lat
        self.endTime, self.endLon, self.endLat = t, lon, lat


if __name__ == '__main__':
    run('0901')
