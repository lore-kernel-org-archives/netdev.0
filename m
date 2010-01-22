From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1 V3] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
Date: Fri, 22 Jan 2010 13:51:16 +0100
Message-ID: <1264164677-6397-1-git-send-email-kristoffer@gaisler.com>
Cc: davem@davemloft.net, Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:49165 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751701Ab0AVMvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 07:51:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.

Third submission. Added use of netif_msg_ interface for controlling debug output.

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    9 +
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1574 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  149 +++++
 5 files changed, 1739 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

