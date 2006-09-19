From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: e1000: fix a typo
Date: Tue, 19 Sep 2006 11:27:24 -0700
Message-ID: <20060919182724.6355.65746.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:44301 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030395AbWISSS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 14:18:29 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 e1000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/e1000.c b/e1000.c
index 6de27ca..6741323 100644
--- a/e1000.c
+++ b/e1000.c
@@ -372,7 +372,7 @@ e1000_dump_regs(struct ethtool_drvinfo *
 		"      Descriptor minimum threshold size: %s\n"
 		"      Broadcast accept mode:             %s\n"
 		"      VLAN filter:                       %s\n"
-		"      Cononical form indicator:          %s\n"
+		"      Canonical form indicator:          %s\n"
 		"      Discard pause frames:              %s\n"
 		"      Pass MAC control frames:           %s\n",
 		reg,

