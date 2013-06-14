From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 6/8] openvswitch: Fix struct comment.
Date: Fri, 14 Jun 2013 15:28:55 -0700
Message-ID: <1371248937-35614-7-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:48667 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753476Ab3FNW3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:29:11 -0400
Received: by mail-pb0-f53.google.com with SMTP id xb12so981968pbc.12
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:29:11 -0700 (PDT)
In-Reply-To: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/uapi/linux/openvswitch.h | 1 -
 1 file changed, 1 deletion(-)

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
1.8.1.2
