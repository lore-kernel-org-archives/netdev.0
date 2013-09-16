From: Fabio Porcedda <fabio.porcedda@gmail.com>
Subject: [PATCH 0/3] net: usb: cdc_ether: improve telit support and code cleanups
Date: Mon, 16 Sep 2013 11:47:49 +0200
Message-ID: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59120 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab3IPJr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:47:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some patches to improve telit modules support and to cleanup the code.

Best regards

Fabio Porcedda (3):
  net: usb: cdc_ether: Use wwan interface for Telit modules
  net: usb: cdc_ether: fix checkpatch errors and warnings
  net: usb: cdc_ether: use usb.h macros whenever possible

 drivers/net/usb/cdc_ether.c | 115 ++++++++++++++++----------------------------
 1 file changed, 42 insertions(+), 73 deletions(-)

-- 
1.8.4
