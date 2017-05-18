From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: couple of fixes
Date: Thu, 18 May 2017 09:18:51 +0200
Message-ID: <20170518071853.12279-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35096 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755096AbdERHTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 03:19:01 -0400
Received: by mail-wm0-f67.google.com with SMTP id v4so8929769wmb.2
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 00:19:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Cuple of fixes from Arkadi

Arkadi Sharshevsky (2):
  mlxsw: spectrum_dpipe: Fix incorrect entry index
  mlxsw: spectrum_router: Fix rif counter freeing routine

 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c  | 3 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

-- 
2.9.3
