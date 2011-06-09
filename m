From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 0/2] bonding: delete two unused variables
Date: Thu,  9 Jun 2011 10:51:32 +0800
Message-ID: <cover.1307587586.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48316 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab1FICvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 22:51:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete two unused variables in bonding.

Weiping Pan (2):
  bonding: delete unused ad_timer
  bonding: delete unused arp_mon_pt

 drivers/net/bonding/bond_3ad.h |    1 -
 drivers/net/bonding/bonding.h  |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

-- 
1.7.4.4

