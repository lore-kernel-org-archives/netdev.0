From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH] neterion: s2io: Fix kernel doc formatting
Date: Sat, 23 May 2015 10:32:55 -0700
Message-ID: <1432402375.29657.56.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0139.hostedemail.com ([216.40.44.139]:41940 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757957AbbEWRc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2015 13:32:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two uses seem to have had carriage returns removed.
Make these entries like all the others in this file.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/neterion/s2io.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 1e0f72b..c281117 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5308,7 +5308,8 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 
 /**
  * s2io_ethtool_sset - Sets different link parameters.
- * @sp : private member of the device structure, which is a pointer to the  * s2io_nic structure.
+ * @sp : private member of the device structure, which is a pointer to the
+ * s2io_nic structure.
  * @info: pointer to the structure with parameters given by ethtool to set
  * link information.
  * Description:
@@ -5793,7 +5794,8 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 
 /**
  *  s2io_ethtool_geeprom  - reads the value stored in the Eeprom.
- *  @sp : private member of the device structure, which is a pointer to the *       s2io_nic structure.
+ *  @sp : private member of the device structure, which is a pointer to the
+ *  s2io_nic structure.
  *  @eeprom : pointer to the user level structure provided by ethtool,
  *  containing all relevant information.
  *  @data_buf : user defined value to be written into Eeprom.
