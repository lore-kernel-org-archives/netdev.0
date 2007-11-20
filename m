From: Joe Perches <joe@perches.com>
Subject: [PATCH 33/59] drivers/net/sk98lin: Add missing "space"
Date: Mon, 19 Nov 2007 17:48:25 -0800
Message-ID: <1195523331-15303-34-git-send-email-joe@perches.com>
References: 1234567
 <1195523331-15303-1-git-send-email-joe@perches.com>
 <1195523331-15303-2-git-send-email-joe@perches.com>
 <1195523331-15303-3-git-send-email-joe@perches.com>
 <1195523331-15303-4-git-send-email-joe@perches.com>
 <1195523331-15303-5-git-send-email-joe@perches.com>
 <1195523331-15303-6-git-send-email-joe@perches.com>
 <1195523331-15303-7-git-send-email-joe@perches.com>
 <1195523331-15303-8-git-send-email-joe@perches.com>
 <1195523331-15303-9-git-send-email-joe@perches.com>
 <1195523331-15303-10-git-send-email-joe@perches.com>
 <1195523331-15303-11-git-send-email-joe@perches.com>
 <1195523331-15303-12-git-send-email-joe@perches.com>
 <1195523331-15303-13-git-send-email-joe@perches.com>
 <1195523331-15303-14-git-send-email-joe@perches.com>
 <1195523331-15303-15-git-send-email-joe@perches.com>
 <1195523331-15303-16-git-send-email-joe@perches.com>
 <1195523331-15303-17-git-send-email-joe@perches.com>
 <1195523331-15303-18-git-send-email-joe@perches.com>
 <1195523331-15303-19-git-send-email-joe@perches.com>
 <1195523331-15303-20-git-send-email-joe@perches.com>
 <1195523331-15303-21-git-send-email-joe@perches.com>
 <1195523331-15303-22-git-send-email-joe@perches.com>
 <1195523331-15303-23-git-send-email-joe@perches.com>
 <1195523331-15303-24-git-send-email-joe@perches.com>
 <1195523331-15303-25-git-send-email-joe@perches.com>
 <1195523331-15303-26-git-send-email-joe@perches.com>
 <1195523331-15303-27-git-send-email-joe@perches.com>
 <1195523331-15303-28-git-send-email-joe@perches.com>
 <1195523331-15303-29-git-send-email-joe@perches.com>
 <1195523331-15303-30-git-send-email-joe@perches.com>
 <1195523331-15303-31-git-send-email-joe@perches.com>
 <1195523331-15303-32-git-send-email-joe@perches.com>
 <1195523331-15303-33-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2120 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756935AbXKTBtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:49:22 -0500
In-Reply-To: <1195523331-15303-33-git-send-email-joe@perches.com>
Message-Id: <938a74cb7895afece561b299f11d28785214bade.1195454435.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sk98lin/skgepnmi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sk98lin/skgepnmi.c b/drivers/net/sk98lin/skgepnmi.c
index b36dd9a..678659f 100644
--- a/drivers/net/sk98lin/skgepnmi.c
+++ b/drivers/net/sk98lin/skgepnmi.c
@@ -383,7 +383,7 @@ int Level)		/* Initialization level */
 			SK_ERR_LOG(pAC, SK_ERRCL_SW, SK_PNMI_ERR049, SK_PNMI_ERR049MSG);
 
 			SK_DBG_MSG(pAC, SK_DBGMOD_PNMI, SK_DBGCAT_INIT | SK_DBGCAT_FATAL,
-					   ("CounterOffset struct size (%d) differs from"
+					   ("CounterOffset struct size (%d) differs from "
 						"SK_PNMI_MAX_IDX (%d)\n",
 						SK_PNMI_CNT_NO, SK_PNMI_MAX_IDX));
 		}
-- 
1.5.3.5.652.gf192c

