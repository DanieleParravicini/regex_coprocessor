#!/usr/bin/env python

from __future__ import print_function

from argparse import ArgumentParser, RawTextHelpFormatter
import re
import sys

import vcdvcd
from vcdvcd import VCDVCD

if __name__ == '__main__':
    parser = ArgumentParser(
        description='Print Verilog value change dump (VCD) files in tabular form.',
        epilog="""
        # Examples
        Show all signals and values:
            vcdcat a.vcd
        Will be too large for any non-trivial design.
        Get the list of all signals:
            vcdcat -l a.vcd
        Show only selected signals:
            vcdcat -x a.vcd top.module.signal1 top.module.signal2
        List all signals that contain the substring "top.":
            vcdcat -l a.vcd top.
        This would show both:
            top.module.signal1
            top.module.signal2
        Now get the values for signals:
            vcdcat a.vcd top.
        """.format(
        f=sys.argv[0]),
        formatter_class=RawTextHelpFormatter,
    )
    parser.add_argument ('-d',    '--deltas',  action='store_true'  ,    default=False,    help='https://github.com/cirosantilli/vcdvcd#vcdcat-deltas')
    parser.add_argument ('-l',    '--list',    action='store_true'  ,    default=False,    help='list signal names and quit')
    group = parser.add_mutually_exclusive_group()
    group.add_argument  ('-x',    '--exact',    action='store_true' ,    default=False,    help='signal names must match exactly, instead of the default substring match')
    group.add_argument  ('-r',    '--regexp',   action='store_true' ,    default=False,    help='signal names are treated as Python regular expressions')
    parser.add_argument ('vcd_path',    metavar='vcd-path')
    parser.add_argument ('signals',     help='only print values for these signals. Substrings of the signal are considered a match by default.',    metavar='signals',    nargs='*')
    args = parser.parse_args()
    vcd = VCDVCD(args.vcd_path, only_sigs=True)
    all_signals = vcd.signals
    if args.signals:
        selected_signals = []
        for s in args.signals:
            r = re.compile(s)
            for a in all_signals:
                if (
                    (args.regexp and r.search(a)) or
                    (args.exact and s == a) or
                    (s in a)
                ):
                    selected_signals.append(a)
    if args.list:
        if args.signals:
            signals = selected_signals
        else:
            signals = all_signals
        print('\n'.join(signals))
    else:
        if args.signals:
            signals = selected_signals
        else:
            signals = []
        if args.deltas:
            callbacks = vcdvcd.PrintDeltasStreamParserCallbacks()
        else:
            callbacks = vcdvcd.PrintDumpsStreamParserCallbacks()
        VCDVCD(
            args.vcd_path,
            signals=signals,
            store_tvs=False,
            callbacks=callbacks,
        )