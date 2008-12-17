From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 v2 0/5] gianfar improvements
Date: Wed, 17 Dec 2008 12:52:56 -0600
Message-ID: <1229539981-14041-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58731 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbYLQSxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 13:53:18 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBHIr3Qv011183
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 11:53:14 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id mBHIr2dd024690
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 12:53:02 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry about previous carelessness, I was using the wrong remote repo for
net-next.  Here are the updated patches against the latest net-next repo

 b/drivers/net/gianfar.c         |    3 
 b/drivers/net/gianfar.h         |    1 
 b/drivers/net/gianfar_ethtool.c |    2 
 drivers/net/gianfar.c           |  320 ++++++++++++++++++++++++----------------
 drivers/net/gianfar.h           |    9 +
 5 files changed, 209 insertions(+), 126 deletions(-)


