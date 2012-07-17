From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] runtime PM support for cpsw and davinci mdio drivers
Date: Tue, 17 Jul 2012 23:39:48 +0530
Message-ID: <1342548590-12502-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34753 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab2GQSJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:09:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for runtime PM support for CPSW and Davinci MDIO
drivers

Mugunthan V N (2):
  driver: net: ethernet: davinci_mdio: runtime PM support
  driver: net: ethernet: cpsw: runtime PM support

 drivers/net/ethernet/ti/cpsw.c         |   23 ++++++++++++++---------
 drivers/net/ethernet/ti/davinci_mdio.c |   25 ++++++++++++-------------
 2 files changed, 26 insertions(+), 22 deletions(-)
