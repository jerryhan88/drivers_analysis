import __init__
from init_project import *
#
from _utils.geoFunctions import get_sgGrid
#
from datetime import datetime
from bisect import bisect
import csv

lons, lats = map(list, get_sgGrid())


def run(processorID, num_workers=11):
    for i, fn in enumerate(os.listdir(dpath['chunkInit'])):
        if not fn.endswith('.csv'):
            continue
        if i % num_workers != processorID:
            continue
        ifpath = opath.join(dpath['chunkInit'], fn)
        did = int(fn[:-len('.csv')].split('-')[-1])
        ofpath = opath.join(dpath['chunkHalfHourZone'], 'chunkHalfHourZone-%d.csv' % did)
        with open(ifpath, 'rb') as r_csvfile:
            reader = csv.reader(r_csvfile)
            header = reader.next()
            hid = {h: i for i, h in enumerate(header)}
            beginCns = ['beginLon', 'beginLat']
            endCns = ['endLon', 'endLat']

            with open(ofpath, 'wt') as w_csvfile:
                writer = csv.writer(w_csvfile, lineterminator='\n')
                new_header = header[:]
                new_header += ['beginHalfHour', 'beginZone',
                               'endHalfHour', 'endZone',]
                writer.writerow(new_header)
                for row in reader:
                    b_hh, e_hh = get_halfHourID(row, hid, 'beginTime'), get_halfHourID(row, hid, 'endTime')
                    b_zi, b_zj = get_zizj(hid, row, beginCns)
                    e_zi, e_zj = get_zizj(hid, row, endCns)
                    new_row = row[:]
                    new_row += [b_hh, 'zi%03d-zj%03d' % (b_zi, b_zj),
                                e_hh, 'zi%03d-zj%03d' % (e_zi, e_zj)]
                    writer.writerow(new_row)


def get_halfHourID(row, hid, timeCn):
    dt = datetime.fromtimestamp(eval(row[hid[timeCn]]))
    return dt.hour * 2 + dt.minute / 30

def get_zizj(hid, row, LonLatCns):
    lon, lat = map(eval, [row[hid[cn]] for cn in LonLatCns])
    return bisect(lons, lon) - 1, bisect(lats, lat) - 1


if __name__ == '__main__':
    run(3)