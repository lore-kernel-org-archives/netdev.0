From: "Brad House" <brad_mssw@gentoo.org>
Subject: [PATCH 2.6.0-test9-bk17] add official BCM5700 driver (instead of tg3 driver)
Date: Sun, 16 Nov 2003 23:13:23 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <47975.68.105.173.45.1069042403.squirrel@mail.mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Because of numerous reported problems with the tg3 driver, mainly
on amd64 (x86_64/Opteron/Athlon64) boxes, we made a kernel patch
from the latest official BCM5700 2.4 driver for the 2.6 kernel.
This seems to resolve those problems, though also seems to be
a much larger driver than the tg3 driver.

http://dev.gentoo.org/~brad_mssw/kernel_patches/2.6.0/genpatches-0.4/302_bcm5700_broadcom_gigabit_drvr.patch

Please CC me on any replies as I am not subscribed to this list.
I also figured it would be ok to submit, as there's the eepro100 and
e100 drivers for the intel nic, figured this was a similar instance.

-Brad House
brad_mssw@gentoo.org
