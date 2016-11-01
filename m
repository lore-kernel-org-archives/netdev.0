From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH net-next 0/2] misc TC/flower changes
Date: Tue,  1 Nov 2016 16:08:27 +0200
Message-ID: <1478009309-63180-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35504 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966175AbcKAOIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 10:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes two small changes to the TC flower classifier.

Thanks,

Roi

Roi Dayan (2):
  net/sched: cls_flower: add missing unbind call when destroying flows
  net/sched: cls_flower: merge filter delete/destroy common code

 net/sched/cls_flower.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

-- 
2.7.4
