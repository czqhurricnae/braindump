# -*- coding: utf-8 -*-
import unicodecsv as csv
import io
import re
from bs4 import BeautifulSoup, NavigableString

if __name__ == '__main__':
    file = open('/Users/c/sap.html').read()
    soup = BeautifulSoup(file, 'html.parser')
    tr_list = soup.find_all('tr')
    with open('/Users/c/sap.csv', 'w+') as f:
        writer = csv.writer(f)
        for tr in tr_list:
            data = []
            for tag in tr.descendants:
                if isinstance(tag, NavigableString):
                    pass
                elif tag.name == u'span':
                    data.append(re.sub(r'\s{2,}', ' ', tag.string).lower())
            writer.writerow(data)
