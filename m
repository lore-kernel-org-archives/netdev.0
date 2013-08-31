From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: correct ixgbevf copyright date
Date: Fri, 30 Aug 2013 22:02:52 -0700
Message-ID: <1377925372-13385-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59447 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502Ab3HaFCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 01:02:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch corrects the copyright date of the ixgbevf code, which was only
recently added.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbevf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ixgbevf.c b/ixgbevf.c
index dae1178..2a3aa6f 100644
--- a/ixgbevf.c
+++ b/ixgbevf.c
@@ -1,4 +1,4 @@
-/* Copyright (c) 2007 Intel Corporation */
+/* Copyright (c) 2013 Intel Corporation */
 #include <stdio.h>
 #include "internal.h"
 
-- 
1.8.3.1
