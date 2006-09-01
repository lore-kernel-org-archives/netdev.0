From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH]: ethtool: typo fix for e1000
Date: Fri, 01 Sep 2006 15:42:00 -0700
Message-ID: <44F8B738.1020001@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030504080109060006050409"
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29592 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1751202AbWIAWnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 18:43:50 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030504080109060006050409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------030504080109060006050409
Content-Type: text/x-patch;
 name="ethtool_git_typo_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ethtool_git_typo_fix.patch"


e1000: Typo fix.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

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

--------------030504080109060006050409--

-- 
VGER BF report: U 0.5
