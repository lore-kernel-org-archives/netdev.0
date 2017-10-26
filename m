From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: small cleanup
Date: Thu, 26 Oct 2017 10:55:31 +0200
Message-ID: <20171026085533.4448-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:54608 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdJZIzg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:55:36 -0400
Received: by mail-wr0-f194.google.com with SMTP id o44so2407825wrf.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 01:55:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of small cleanup patches from Nogah.

Nogah Frankel (2):
  mlxsw: spectrum: Change stats cache to be local
  mlxsw: reg: Avoid magic number in PPCNT

 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 72 +++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 24 +++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  4 +-
 3 files changed, 51 insertions(+), 49 deletions(-)

-- 
2.9.5
