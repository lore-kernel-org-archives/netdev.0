From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/2] atl1: minor cleanup
Date: Sun, 29 Apr 2007 21:42:09 -0500
Message-ID: <11779009311121-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf07aec.mail.bellsouth.net ([205.152.59.55]:33213 "EHLO
	imf07aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422824AbXD3DOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 23:14:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please accept the following trivial patches to the atl1 driver.

- use dev_printk macros
- fix whitespace damage

 drivers/net/atl1/atl1_ethtool.c |   19 +++------
 drivers/net/atl1/atl1_hw.c      |   44 ++++++++++-----------
 drivers/net/atl1/atl1_main.c    |   83 +++++++++++++++++---------------------
 drivers/net/atl1/atl1_param.c   |   31 +++++++--------
 4 files changed, 79 insertions(+), 98 deletions(-)
