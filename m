From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/1] smsc75xx: wol enhancements
Date: Tue, 30 Oct 2012 17:46:31 +0000
Message-ID: <1351619192-11022-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:41404 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965014Ab2J3Rqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 13:46:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for more WOL frame types to smsc75xx,
similarly to a patch recently submitted for smsc95xx.

Please review and consider for inclusion into net-next.

Steve Glendinning (1):
  smsc75xx: add wol support for more frame types

 drivers/net/usb/Kconfig    |    2 +
 drivers/net/usb/smsc75xx.c |  155 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 124 insertions(+), 33 deletions(-)

-- 
1.7.10.4
