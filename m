From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
Date: Mon, 25 Jan 2010 12:01:11 +0100
Message-ID: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>
Cc: davem@davemloft.net, Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail168c2.megamailservers.com ([69.49.111.68]:42772 "EHLO
	mail168c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751494Ab0AYLB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 06:01:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.

Fourth submission. Removes warnings introduced by last patch ...

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    9 +
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1573 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  149 +++++
 5 files changed, 1738 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

