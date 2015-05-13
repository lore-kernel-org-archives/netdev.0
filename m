From: sfeldma@gmail.com
Subject: [PATCH net-next 3/4] switchdev: align comment with other comments in block
Date: Tue, 12 May 2015 23:03:53 -0700
Message-ID: <1431497034-22153-4-git-send-email-sfeldma@gmail.com>
References: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36554 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbbEMGCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:02:53 -0400
Received: by pabsx10 with SMTP id sx10so39732802pab.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:02:52 -0700 (PDT)
In-Reply-To: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 3b217b4..9f9a7cc5 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -53,7 +53,7 @@ struct switchdev_obj {
 	enum switchdev_obj_id id;
 	enum switchdev_trans trans;
 	union {
-		struct switchdev_obj_vlan {			/* PORT_VLAN */
+		struct switchdev_obj_vlan {		/* PORT_VLAN */
 			u16 flags;
 			u16 vid_start;
 			u16 vid_end;
-- 
1.7.10.4
