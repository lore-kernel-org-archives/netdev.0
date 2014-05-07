From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3 RESEND] bonding: slight optimization and cleanup
Date: Wed, 7 May 2014 22:10:18 +0800
Message-ID: <1399471821-11252-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29524 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbaEGOLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 10:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: fix some wrong format for patch 1.

Ding Tianhong (3):
  bonding: remove the unnecessary struct bond_net
  bonding: simplify the slave_do_arp_validate_only()
  bonding: remove the unused macro

 drivers/net/bonding/bond_main.c |  4 ++--
 drivers/net/bonding/bonding.h   | 23 +++++++++--------------
 2 files changed, 11 insertions(+), 16 deletions(-)

-- 
1.8.0
