From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/5 2.4.27] pending pcnet32 changes
Date: Mon, 9 Aug 2004 16:12:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809231247.GA13717@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply these five patches to bring the 2.4 version of pcnet32.c up
to date with 2.6.  

1 - discard oversize received frames
2 - fix receive hang after tx fifo underruns
3 - cleanup IRQ limitation
4 - add HomePNA parameter for 79C978
5 - correctly program bcr32

-- 
Don Fry
brazilnut@us.ibm.com
