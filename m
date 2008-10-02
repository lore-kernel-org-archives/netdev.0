From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Thu,  2 Oct 2008 16:27:56 +0100
Message-ID: <1222961277-3155-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:58433 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753541AbYJBP2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 11:28:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attached is a driver for SMSC's LAN9500 USB 2.0 10/100 ethernet adapter, 
please consider for inclusion in 2.6.28.

Reposting following additional feedback from Ben Hutchings.

--
 MAINTAINERS                |    6 +
 drivers/net/usb/Kconfig    |    8 +
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/smsc95xx.c | 1225 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/smsc95xx.h |  253 +++++++++
 5 files changed, 1493 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/smsc95xx.c
 create mode 100644 drivers/net/usb/smsc95xx.h

