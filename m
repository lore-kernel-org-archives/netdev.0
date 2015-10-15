From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/15] mlxsw: reg: Uppercase letters in register IDs
Date: Thu, 15 Oct 2015 17:43:23 +0200
Message-ID: <1444923809-20785-10-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34980 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbbJOPnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:43 -0400
Received: by lffy185 with SMTP id y185so33149864lff.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:42 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 5e0c957..a2ebb79 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -161,7 +161,7 @@ static inline void mlxsw_reg_sspr_pack(char *payload, u8 local_port)
  * -------------------------------------------
  * Configures the spanning tree state of a physical port.
  */
-#define MLXSW_REG_SPMS_ID 0x200d
+#define MLXSW_REG_SPMS_ID 0x200D
 #define MLXSW_REG_SPMS_LEN 0x404
 
 static const struct mlxsw_reg_info mlxsw_reg_spms = {
@@ -962,7 +962,7 @@ static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port)
  * Controls the association of a port with a switch partition and enables
  * configuring ports as stacking ports.
  */
-#define MLXSW_REG_PSPA_ID 0x500d
+#define MLXSW_REG_PSPA_ID 0x500D
 #define MLXSW_REG_PSPA_LEN 0x8
 
 static const struct mlxsw_reg_info mlxsw_reg_pspa = {
-- 
1.9.3
