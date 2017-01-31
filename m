From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next 0/2] net/sched: act_sample: Little fixes
Date: Tue, 31 Jan 2017 11:33:52 +0200
Message-ID: <1485855234-9941-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46476 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751098AbdAaJcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:32:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Little fixes in sample tc action.

Yotam Gigi (2):
  net/sched: act_sample: Fix error path in init
  net/sched: act_psample: Remove unnecessary ASSERT_RTNL

 net/sched/act_sample.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

-- 
2.4.11
