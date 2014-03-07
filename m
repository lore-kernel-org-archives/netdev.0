From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] vlan: add proto for vlan proc interface
Date: Fri, 7 Mar 2014 20:10:49 +0800
Message-ID: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:19463 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbaCGMLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:11:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  vlan: add proto for proc interface
  vlan: add proto and regulate the /proc/net/vlan/config

 net/8021q/vlanproc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

-- 
1.8.0
