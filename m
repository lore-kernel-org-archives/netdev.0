From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] vlan: slight optimization for vlan core
Date: Fri, 7 Mar 2014 18:45:29 +0800
Message-ID: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4663 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaCGKqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:46:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  vlan: slight optimization for vlan_do_receive()
  vlan: use use ether_addr_equal_64bits to instead of ether_addr_equal

 net/8021q/vlan_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.8.0
