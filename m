From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Mon, 29 Sep 2008 15:30:23 +0100
Message-ID: <1222698624-3689-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:36783 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750940AbYI2Oa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 10:30:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attached is a driver for SMSC's LAN9500 USB2.0 10/100 ethernet adapter, 
incorporating feedback from netdev.  Please consider for inclusion in 
2.6.28.

Reposting for inclusion in patchwork.

 MAINTAINERS                |    6 +
 drivers/net/usb/Kconfig    |    8 +
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/smsc95xx.c | 1211 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/smsc95xx.h |  253 +++++++++
 5 files changed, 1479 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/smsc95xx.c
 create mode 100644 drivers/net/usb/smsc95xx.h

