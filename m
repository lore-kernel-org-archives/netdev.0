From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.4.26 - r8169 backport
Date: Tue, 20 Apr 2004 23:27:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040420232702.A2543@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Chen-Bin Su <cbs@paralleldata.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A backport of the 2.6.6-rc1 r8169 driver against 2.4.26 is available.

All in one patch against 2.4.26:
  http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.26/r8169-mammoth-attack.patch

Individual files:
  http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.26

Tarball:
  http://www.fr.zoreil.com/linux/kernel/2.4.x/2.4.26/r8169-blob.tar.bz2

I will surely extract the part related to the Tx loop in the irq handler and
submit it for 2.4.x as a bugfix. I have no strong feeling about the remaining
parts though.

Please Cc: netdev@oss.sgi.com if something goes wrong.

--
Ueimor
