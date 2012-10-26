From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/1] smsc95xx: wol enhancements
Date: Fri, 26 Oct 2012 14:43:55 +0100
Message-ID: <1351259036-5375-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:56776 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932950Ab2JZNoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 09:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for more WOL frame types to smsc95xx.

Please review and consider for inclusion into net-next.

Steve Glendinning (1):
  smsc95xx: add wol support for more frame types

 drivers/net/usb/Kconfig    |    2 +
 drivers/net/usb/smsc95xx.c |  127 +++++++++++++++++++++++++++++++++++++++++---
 drivers/net/usb/smsc95xx.h |    5 ++
 3 files changed, 128 insertions(+), 6 deletions(-)

-- 
1.7.9.5
