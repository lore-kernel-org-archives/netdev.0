From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 0/2] be2net fixes
Date: Mon, 25 Jun 2012 11:08:12 +0530
Message-ID: <a5b0dbf3-1d39-41a2-9723-b28abd578852@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3569 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab2FYFob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 01:44:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Somnath Kotur (2):
  be2net: Explicitly clear the reserved field in the Tx Descriptor
  be2net: Regression bug wherein VFs creation broken for multiple
    cards.

 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 1 files changed, 3 insertions(+), 1 deletions(-)
