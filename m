From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] ravb: fix the fallout of R-Car gen3 gPTP support
Date: Sat, 06 Feb 2016 17:45:37 +0300
Message-ID: <15000430.RmSAhz5Ejy@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo fixing up the
incomplete commit f5d7837f96e5 ("ravb: ptp: Add CONFIG mode support").
I'm proposing these as fixes but they can be merged as cleanups as well...

[1/2] ravb: kill duplicate setting of CCC.CSEL
[2/2] ravb: skip gPTP start/stop on R-Car gen3

MBR, Sergei
