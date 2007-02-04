From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH netdev#atl1 0/3] atl1: fix whitespace, add maintainers and pci_ids
Date: Sat, 3 Feb 2007 20:22:48 -0600
Message-ID: <20070204022248.GA4063@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf25aec.mail.bellsouth.net ([205.152.59.73]:59783 "EHLO
	imf25aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751880AbXBDCWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 21:22:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches completes the final bit of tidying up in the Attansic
ethernet driver.  Sorry for nickel-and-diming you, Jeff, but this really
should be the end of it for awhile.

Summary:
1.  Clean up whitespace damage.
2.  Add a maintainers entry.
3.  Add a pci_ids entry.
---
 MAINTAINERS                     |   10 +++
 drivers/net/atl1/atl1.h         |   12 ++--
 drivers/net/atl1/atl1_ethtool.c |  120 +++++++++++++++++++++++++++-------
 drivers/net/atl1/atl1_hw.h      |   14 ++--
 drivers/net/atl1/atl1_main.c    |  137 +++++++++++++++++++--------------------
 drivers/net/atl1/atl1_param.c   |   22 +++---
 include/linux/pci_ids.h         |    2 +
 7 files changed, 200 insertions(+), 117 deletions(-)
