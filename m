From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/5] atl1: additional patches for 2.6.23
Date: Thu, 19 Jul 2007 18:45:09 -0500
Message-ID: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:57597 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759239AbXGSXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please accept the following patches for the atl1 driver.  Thanks.

atl1: use kernel provided ethernet length constants
atl1: fix typo in dma_req_block
atl1: change cmb write threshold
atl1: fix typo in DMA engine setup
atl1: change tpd_avail function name

 drivers/net/atl1/atl1_hw.h   |    9 ++-------
 drivers/net/atl1/atl1_main.c |   26 +++++++++++++++-----------
 2 files changed, 17 insertions(+), 18 deletions(-)
