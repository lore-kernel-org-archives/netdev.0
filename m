From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1 V2] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
Date: Mon, 18 Jan 2010 16:07:56 +0100
Message-ID: <1263827277-7165-1-git-send-email-kristoffer@gaisler.com>
Cc: bhutchings@solarflare.com,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail168c2.megamailservers.com ([69.49.111.68]:53095 "EHLO
	mail168c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752719Ab0ARPIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 10:08:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver adds support for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MACs.

This is the second round for this patch. I have incorporated fixes suggested by Ben Hutchings
after reviewing (parts) of the original patch.

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    9 +
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1538 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  147 +++++
 5 files changed, 1701 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

