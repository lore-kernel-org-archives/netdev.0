From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 0/4] gianfar: Misc. fixes and updates
Date: Fri, 23 Oct 2015 11:41:57 +0300
Message-ID: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0142.outbound.protection.outlook.com ([65.55.169.142]:33792
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750905AbbJWImQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 04:42:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various fixes for some older issues, including having a
MAINTAINERS entry for this driver.
I'd recommend applying them on top of net, thanks.

Claudiu Manoil (4):
  gianfar: Remove duplicated argument to bitwise OR
  gianfar: Don't enable the Filer w/o the Parser
  gianfar: Fix Rx BSY error handling
  MAINTAINERS: Add entry for gianfar ethernet driver

 MAINTAINERS                                      | 8 ++++++++
 drivers/net/ethernet/freescale/gianfar.c         | 8 +++-----
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 4 ++--
 3 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.7.11.7
