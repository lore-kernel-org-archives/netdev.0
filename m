From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 0/2] remove duplicate set of flag IFF_MULTICAST
Date: Wed, 16 Mar 2016 09:59:14 +0000
Message-ID: <1458122356-25021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, j.vosburgh@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8342 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933901AbcCPJyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:54:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series remove duplicate set of flag IFF_MULTICAST.

Zhang Shengju (2):
  bonding: remove duplicate set of flag IFF_MULTICAST
  team: remove duplicate set of flag IFF_MULTICAST

 drivers/net/bonding/bond_main.c | 2 +-
 drivers/net/team/team.c         | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

-- 
1.8.3.1
