From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 0/6] bonding:fix checkpatch errors or warning.
Date: Fri, 14 Feb 2014 17:15:11 +0800
Message-ID: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64249 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbaBNJPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

Wang Yufen (6):
  bonding:fix checkpatch errors with foo* bar|foo * bar
  bonding:fix checkpatch errors comments and space
  bonding:fix checkpatch warnings braces {}
  bonding:fix checkpatch warnings braces {}
  bonding:fix checkpatch warnings braces {}
  bonding:fix checkpatch warnings braces {}

 drivers/net/bonding/bond_alb.c | 83 +++---
 1 file changed, 30 insertions(+), 53 deletions(-)

 -- 
1.7.12
