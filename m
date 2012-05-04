From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/3] smsc75xx: more minor fixes
Date: Fri,  4 May 2012 11:57:10 +0100
Message-ID: <1336129033-15826-1-git-send-email-steve.glendinning@shawell.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:55613 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab2EDK5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 06:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 more minor patches for smsc75xx

Steve Glendinning (3):
  smsc75xx: replace 0xffff with PHY_INT_SRC_CLEAR_ALL
  smsc75xx: eliminate unnecessary phy register read
  smsc75xx: let EEPROM determine GPIO/LED settings

 drivers/net/usb/smsc75xx.c |   26 +++++++++++++++-----------
 drivers/net/usb/smsc75xx.h |    1 +
 2 files changed, 16 insertions(+), 11 deletions(-)

-- 
1.7.9.5
