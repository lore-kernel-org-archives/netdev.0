From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: spectrum: Remove extra whitespace
Date: Thu, 27 Oct 2016 15:12:57 +0200
Message-ID: <1477573981-26546-2-git-send-email-jiri@resnulli.us>
References: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36456 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942655AbcJ0OWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:22:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id c17so2957017wmc.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:22:51 -0700 (PDT)
In-Reply-To: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 113f667..107934f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1980,7 +1980,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_vrs_init;
 
-	err =  mlxsw_sp_neigh_init(mlxsw_sp);
+	err = mlxsw_sp_neigh_init(mlxsw_sp);
 	if (err)
 		goto err_neigh_init;
 
-- 
2.5.5
