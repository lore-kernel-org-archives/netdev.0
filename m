From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] i40e: remove broken link.
Date: Sat, 20 Feb 2016 10:59:39 +0200
Message-ID: <1455958779-13399-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, Rami Rosen <rami.rosen@intel.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44341 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992561AbcBTI6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2016 03:58:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a broken link from Documentation/networking/i40e.txt.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 Documentation/networking/i40e.txt | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/Documentation/networking/i40e.txt b/Documentation/networking/i40e.txt
index a251bf4..09f8f3b 100644
--- a/Documentation/networking/i40e.txt
+++ b/Documentation/networking/i40e.txt
@@ -88,15 +88,6 @@ Additional Configurations
 
   Where n=the VF that attempted to do the spoofing.
 
-
-Performance Tuning
-==================
-
-An excellent article on performance tuning can be found at:
-
-http://www.redhat.com/promo/summit/2008/downloads/pdf/Thursday/Mark_Wagner.pdf
-
-
 Known Issues
 ============
 
-- 
1.9.3
