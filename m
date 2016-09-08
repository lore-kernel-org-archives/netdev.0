From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Thu,  8 Sep 2016 08:16:00 +0200
Message-ID: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36344 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbcIHGQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:16:06 -0400
Received: by mail-wm0-f53.google.com with SMTP id b187so149590087wme.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:16:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Ido and myself.

Ido Schimmel (1):
  mlxsw: spectrum: Set port type before setting its address

Jiri Pirko (1):
  mlxsw: spectrum_router: Fix error path in mlxsw_sp_router_init

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c        | 18 +++++++++---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c |  9 ++++++++-
 2 files changed, 17 insertions(+), 10 deletions(-)

-- 
2.5.5
