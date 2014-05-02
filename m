From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/2] be2net: Patch fixes
Date: Fri, 2 May 2014 14:45:55 -0500
Message-ID: <20140502194555.GA20214@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:6072 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaEBTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:45:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixes against net tree. Please apply.

Ajit Khaparde (1):
  be2net: Reset multicast promiscuous mode when its enabled

Suresh Reddy (1):
  be2net: Poll for link status till 5s in ethtool diag test

 drivers/net/ethernet/emulex/benet/be_cmds.c    |  8 +++++---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 15 ++++++++++++++-
 2 files changed, 19 insertions(+), 4 deletions(-)

-- 
1.8.3.2
