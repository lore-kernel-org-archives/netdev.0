From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Wed, 24 Aug 2016 11:18:50 +0200
Message-ID: <1472030332-6208-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33715 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754651AbcHXJb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 05:31:58 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so1763204wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 02:31:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (1):
  mlxsw: spectrum: Add missing flood to router port

Yotam Gigi (1):
  mlxsw: router: Enable neighbors to be created on stacked devices

 drivers/net/ethernet/mellanox/mlxsw/port.h         |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 43 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  2 +-
 3 files changed, 44 insertions(+), 2 deletions(-)

-- 
2.5.5
