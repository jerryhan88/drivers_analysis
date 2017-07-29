import __init__
from init_project import *
#
from datetime import datetime
import csv

HOUR4 = 4 * 60 * 60


def run(processorID, num_workers=11):
    for i, fn in enumerate(os.listdir(dpath['arranged'])):
        if not fn.endswith('.csv'):
            continue
        if i % num_workers != processorID:
            continue
        ifpath = opath.join(dpath['arranged'], fn)
        did = int(fn[:-len('.csv')].split('-')[-1])
        ofpath = opath.join(dpath['chunkInit'], 'chunkInit-%d.csv' % did)
        with open(ofpath, 'wt') as w_csvfile:
            writer = csv.writer(w_csvfile, lineterminator='\n')
            header = ['did',
                      'beginTime', 'beginLon', 'beginLat',
                      'endTime', 'endLon', 'endLat',
                      'duration',
                      'year', 'month', 'day']
            writer.writerow(header)
        cc = None
        with open(ifpath, 'rb') as r_csvfile:
            reader = csv.reader(r_csvfile)
            header = reader.next()
            hid = {h: i for i, h in enumerate(header)}
            for row in reader:
                beginTime, beginLon, beginLat = map(eval, [row[hid[cn]] for cn in ['beginTime', 'beginLon', 'beginLat']])
                endTime, endLon, endLat = map(eval, [row[hid[cn]] for cn in ['endTime', 'endLon', 'endLat']])
                if not cc:
                    cc = chunk(beginTime, beginLon, beginLat, endTime, endLon, endLat)
                else:
                    if beginTime - cc.endTime < HOUR4:
                        cc.endTime, cc.endLon, cc.endLat = endTime, endLon, endLat
                    else:
                        with open(ofpath, 'a') as w_csvfile:
                            writer = csv.writer(w_csvfile, lineterminator='\n')
                            dt = datetime.fromtimestamp(cc.beginTime)
                            new_row = [did,
                                       cc.beginTime, cc.beginLon, cc.beginLat,
                                       cc.endTime, cc.endLon, cc.endLat,
                                       cc.endTime - cc.beginTime,
                                       dt.year, dt.month, dt.day
                                       ]
                            writer.writerow(new_row)
                        cc = chunk(beginTime, beginLon, beginLat, endTime, endLon, endLat)


class chunk(object):
    def __init__(self, beginTime, beginLon, beginLat, endTime, endLon, endLat):
        #
        self.beginTime, self.beginLon, self.beginLat, \
        self.endTime, self.endLon, self.endLat = beginTime, beginLon, beginLat, endTime, endLon, endLat


if __name__ == '__main__':
    run(3)