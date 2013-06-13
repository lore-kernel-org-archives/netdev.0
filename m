From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 3/4] openvswitch: Fix struct comment.
Date: Thu, 13 Jun 2013 11:11:39 -0700
Message-ID: <1371147099-29256-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:38737 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758129Ab3FMSLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:11:42 -0400
Received: by mail-pb0-f44.google.com with SMTP id uo1so5888910pbc.17
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:11:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2:
no change.
---
 include/uapi/linux/openvswitch.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 405918d..424672d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -192,7 +192,6 @@ enum ovs_vport_type {
  * optional; if not specified a free port number is automatically selected.
  * Whether %OVS_VPORT_ATTR_OPTIONS is required or optional depends on the type
  * of vport.
- * and other attributes are ignored.
  *
  * For other requests, if %OVS_VPORT_ATTR_NAME is specified then it is used to
  * look up the vport to operate on; otherwise dp_idx from the &struct
-- 
1.7.1
