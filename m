From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] e100.txt: Cleanup license info in kernel doc
Date: Thu,  3 Dec 2015 13:57:52 -0800
Message-ID: <1449179874-49174-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John Ronciak <john.ronciak@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbbLCV54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:57:56 -0500
In-Reply-To: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently the e100.txt document contained a "License" section left
over from days of old, which does not need to be in the kernel
documentation.  So clean it up..

CC: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 Documentation/networking/e100.txt | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/Documentation/networking/e100.txt b/Documentation/networking/e100.txt
index f862cf3..42ddbd4 100644
--- a/Documentation/networking/e100.txt
+++ b/Documentation/networking/e100.txt
@@ -181,17 +181,3 @@ For general information, go to the Intel support website at:
 If an issue is identified with the released source code on the supported
 kernel with a supported adapter, email the specific information related to the
 issue to e1000-devel@lists.sourceforge.net.
-
-
-License
-=======
-
-This software program is released under the terms of a license agreement
-between you ('Licensee') and Intel. Do not use or load this software or any
-associated materials (collectively, the 'Software') until you have carefully
-read the full terms and conditions of the file COPYING located in this software
-package. By loading or using the Software, you agree to the terms of this
-Agreement. If you do not agree with the terms of this Agreement, do not install
-or use the Software.
-
-* Other names and brands may be claimed as the property of others.
-- 
2.5.0
