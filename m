From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/2] Additions to new smsc9420 driver
Date: Thu, 11 Dec 2008 11:01:50 +0000
Message-ID: <1228993312-16738-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:55102 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754950AbYLKLBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 06:01:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two patches to add additional features to the new smsc9420 driver

Steve Glendinning (2):
  smsc9420: add netpoll support
  smsc9420: add ethtool eeprom support

 drivers/net/smsc9420.c |  133 ++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/smsc9420.h |    3 +
 2 files changed, 136 insertions(+), 0 deletions(-)

