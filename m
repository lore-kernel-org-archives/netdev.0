From: <ilant@mellanox.com>
Subject: [PATCH net v2 0/1] xfrm: Fix NETDEV_DOWN with IPSec offload
Date: Mon, 8 May 2017 10:39:33 +0300
Message-ID: <20170508073934.28529-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>, <netdev@vger.kernel.org>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00087.outbound.protection.outlook.com ([40.107.0.87]:15232
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751982AbdEHHjq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 03:39:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

v1 -> v2: Added Fixes tag

Ilan Tayari (1):
  xfrm: Fix NETDEV_DOWN with IPSec offload

 net/xfrm/xfrm_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.11.0
