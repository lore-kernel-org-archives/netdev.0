From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 0/2] remove bridge BRIDGE_MODE_SWDEV
Date: Fri,  5 Dec 2014 17:16:42 -0800
Message-ID: <1417828604-42722-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:42124 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaLFBQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 20:16:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (2):
  bridge: remove mode 'swdev'
  rocker: remove swdev mode

 drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
 include/uapi/linux/if_bridge.h       |    1 -
 2 files changed, 1 insertion(+), 18 deletions(-)

-- 
1.7.10.4
