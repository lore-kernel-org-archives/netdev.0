From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: forcedeth: version 0.18 available
Date: Thu, 20 Nov 2003 07:11:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC5B04.50801@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

version 0.18 of forcedeth for Linux 2.4 and 2.6 is available at
http://www.hailfinger.org/carldani/linux/patches/forcedeth/
It is also integrated in 2.6.0-test9-mm4.

Fixes in this release over 0.17:
*  Avoid Oops on rmmod.

Known issues:
*  Some boards give bogus MAC addresses and work only partially.
   Same problem happens with nvnet on these boards.
*  Possible system slowdown during periods of extreme network
   load, fix is currently being tested.

Please test.


Regards,
Carl-Daniel
