From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] ethtool: fix typo in man page
Date: Tue,  6 Oct 2015 10:07:36 +0200
Message-ID: <1444118856-6211-1-git-send-email-ivecera@redhat.com>
To: bwh@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbbJFIHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 04:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 ethtool.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index ae56293..eeffa70 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -872,7 +872,7 @@ Enables/disables the device support of EEE.
 Determines whether the device should assert its Tx LPI.
 .TP
 .BI advertise \ N
-Sets the speeds for which the device should advertise EEE capabiliities.
+Sets the speeds for which the device should advertise EEE capabilities.
 Values are as for
 .B \-\-change advertise
 .TP
-- 
2.4.9
