From: Adam.Torgerson@colorado.edu
Subject: Issue Report: forcedeth v0.23, irq with unknown events
Date: Sat,  6 Mar 2004 18:53:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1078624409.404a80995e634@webmail.colorado.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I'm getting tons of these kernel messages:

"eth0: received irq with unknown events 0x1. Please report"

on an Abit NF7 (nforce2 Ultra400 + MCP-T is what the box says), so I figured I
better report it. The driver works, but is quite slow (only 256kB/s on a local
100Mbit network). lspci shows the device as:

00:04.0 Ethernet controller: nVidia Corporation nForce2 Ethernet Controller (rev
a1)

Currently using 2.6.4-rc1-mm2. Let me know if I can provide any more information
(please CC me as I'm not on any lists).

Thanks for the driver and keep up the good work,
Adam
