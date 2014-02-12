From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] bonding: remove the redundant judgements for bonding
Date: Wed, 12 Feb 2014 14:58:48 +0800
Message-ID: <1392188330-17208-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26694 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaBLG7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 01:59:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the redundant judgements for bond_set_mac_address() and
bond_option_queue_id_set().

Ding Tianhong (2):
  bonding: remove the redundant judgements for bond_set_mac_address()
  bonding: remove the redundant judgements for
    bond_option_queue_id_set()

 drivers/net/bonding/bond_main.c    | 8 --------
 drivers/net/bonding/bond_options.c | 3 +--
 2 files changed, 1 insertion(+), 10 deletions(-)

-- 
1.8.0
