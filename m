From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 0/3] be2net: patch series
Date: Mon, 16 May 2011 23:06:01 +0530
Message-ID: <97ee12ca-4d87-4cff-bc15-fec8930d7ac3@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37878 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753610Ab1EPRgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:36:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please Apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (3):
  be2net: Support for version 1 of stats for BE3
  be2net: Stats for Lancer
  be2net: FW download for Lancer

 drivers/net/benet/be.h         |   38 ++++
 drivers/net/benet/be_cmds.c    |  161 +++++++++++++++-
 drivers/net/benet/be_cmds.h    |  414 +++++++++++++++++++++++++++++++++++++---
 drivers/net/benet/be_ethtool.c |  108 ++++-------
 drivers/net/benet/be_main.c    |  386 ++++++++++++++++++++++++++++++++-----
 5 files changed, 956 insertions(+), 151 deletions(-)

