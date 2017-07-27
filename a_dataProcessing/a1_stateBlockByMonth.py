import __init__
from init_project import *
#
import csv

log_postfixs = ['-normal.csv', '-outside.csv', '-special.csv', '-unknown.csv']
MIN20 = 20 * 60


def run(yymm):
    ofpath = opath.join(dpath['stateBlockByMonth'], 'stateBlockByMonth-%s.csv' % yymm)
    yy, mm = yymm[:2], yymm[2:]
    yyyy = '20%s' % yy
    log_dir = opath.join(TAXI_HOME, '%s/%s/logs' % (yyyy, mm))
    # log_dir = '.'
    log_fpaths = [opath.join(log_dir, 'logs-%s%s' % (yymm, postfix)) for postfix in log_postfixs]
    csvReaders = {i: csv.reader(open(fpath, 'rb')) for i, fpath in enumerate(log_fpaths)}
    header = None
    for reader in csvReaders.itervalues():
        header = reader.next()
    hid = {h: i for i, h in enumerate(header)}
    rows = {i: reader.next() for i, reader in csvReaders.iteritems()}
    vid_stateBlocks = {}
    while csvReaders:
        minT, minID = 1e400, -1
        for i, row in rows.iteritems():
            t = eval(row[hid['time']])
            if t < minT:
                minT, minID = t, i
        minT_row = rows[minID]
        t = eval(minT_row[hid['time']])
        assert t == minT
        vid, did, state = map(int, [minT_row[hid[cn]] for cn in ['vehicle-id', 'driver-id', 'state']])
        lon, lat = map(eval, [minT_row[hid[cn]] for cn in ['longitude', 'latitude']])
        if did == -1:
            lookup_next_row(minID, rows, csvReaders)
            continue
        #
        if not vid_stateBlocks.has_key(vid):
            vid_stateBlocks[vid] = [stateBlock(did, state, t, lon, lat)]
        else:
            lsb = vid_stateBlocks[vid][-1]
            if state == lsb.state:
                if t - lsb.endTime > MIN20:
                    vid_stateBlocks[vid].append(stateBlock(did, state, t, lon, lat))
                else:
                    lsb.endTime, lsb.endLon, lsb.endLat = t, lon, lat
            else:
                vid_stateBlocks[vid].append(stateBlock(did, state, t, lon, lat))
        lookup_next_row(minID, rows, csvReaders)

    with open(ofpath, 'wt') as w_csvfile:
        writer = csv.writer(w_csvfile, lineterminator='\n')
        header = ['did', 'state',
                  'beginTime', 'beginLon', 'beginLat',
                  'endTime', 'endLon', 'endLat',
                  'duration']
        writer.writerow(header)
        for stateBlocks in vid_stateBlocks.itervalues():
            for sb in stateBlocks:
                writer.writerow([sb.did, sb.state,
                                 sb.beginTime, sb.beginLon, sb.beginLat,
                                 sb.endTime, sb.endLon, sb.endLat,
                                 sb.endTime - sb.beginTime])

def lookup_next_row(minID, rows, csvReaders):
    try:
        rows[minID] = csvReaders[minID].next()
    except StopIteration:
        csvReaders.pop(minID)
        rows.pop(minID)


class stateBlock(object):
    def __init__(self, did, state, t, lon, lat):
        self.did, self.state = did, state
        #
        self.beginTime, self.beginLon, self.beginLat = t, lon, lat
        self.endTime, self.endLon, self.endLat = t, lon, lat


if __name__ == '__main__':
    run('0901')
