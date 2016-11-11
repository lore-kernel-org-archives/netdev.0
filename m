From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Fri, 11 Nov 2016 11:20:40 +0100
Message-ID: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, arkadis@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37414 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751606AbcKKKUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 05:20:45 -0500
Received: by mail-wm0-f54.google.com with SMTP id t79so83236621wmt.0
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 02:20:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Please, queue-up both for stable. Thanks!

Arkadi Sharshevsky (1):
  mlxsw: spectrum_router: Correctly dump neighbour activity

Yotam Gigi (1):
  mlxsw: spectrum: Fix refcount bug on span entries

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 11 ++++++-----
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++++++-
 2 files changed, 27 insertions(+), 6 deletions(-)

-- 
2.7.4
