From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 0/5] dscc4: short summary for the serie of patches
Date: Fri, 14 Jan 2005 01:07:32 +0100
Message-ID: <20050114000732.GA28864@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The dscc4 driver has inherited a missing initialization bug since the
internals of the struct hdlc_dev was reworked (!). Now it kills the
driver at startup. The first patch of the incoming serie fixes it.

I would appreciate if it could be included in mainline for the next
release. The remaining patches are not critical.

Patches are archived as:
o patch-script
  http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc1/dscc4
o tar-ball
  http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc1/dscc4-blob.tar.bz2

--
Ueimor
