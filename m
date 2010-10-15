From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Subject: [PATCH 0/1] ARC vmac ethernet driver.
Date: Fri, 15 Oct 2010 09:54:13 +0200
Message-ID: <1287129254-18078-1-git-send-email-andreas.fenkart@streamunlimited.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:47903 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752111Ab0JOHwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 03:52:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a driver for the MAC IP block from Arc international. It
is based on an existing driver found in Arc linux distribution,
but essentially, it is a full rewrite. Influenced heavily by
dnet/bcm63xx_enet drivers. 

This is a resubmission, changes are:

- Kconfig dependencies, HAS_DMA/CRC32/PHYLIB/MII

- removed mac_addr module parameter

- rebased linux tree: 3b72090a7317a034d1276a8fbe3b68c3cb77bd92

regards

Andreas


