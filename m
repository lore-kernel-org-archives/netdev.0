From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1] net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet MAC driver
Date: Fri,  8 Jan 2010 16:45:30 +0100
Message-ID: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>
Cc: Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail176c2.megamailservers.com ([69.49.111.76]:33462 "EHLO
	mail176c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455Ab0AHQDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 11:03:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver adds support for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MACs.

Tested on SPARC32 (LEON) as well as build tested on PPC64.

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |   48 ++
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1384 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  154 ++++++
 5 files changed, 1593 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

