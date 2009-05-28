From: Matt Kraai <kraai@ftbfs.org>
Subject: [PATCH] Ignore .cis files
Date: Thu, 28 May 2009 06:33:25 -0700
Message-ID: <1243517605-7034-1-git-send-email-kraai@ftbfs.org>
Cc: Matt Kraai <kraai@ftbfs.org>
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omail.authdirect.com ([204.13.82.145]:49990 "HELO
	omail.authdirect.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with SMTP id S1763100AbZE1Nmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 09:42:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matt Kraai <kraai@ftbfs.org>
---
 firmware/cis/.gitignore |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)
 create mode 100644 firmware/cis/.gitignore

diff --git a/firmware/cis/.gitignore b/firmware/cis/.gitignore
new file mode 100644
index 0000000..1de3984
--- /dev/null
+++ b/firmware/cis/.gitignore
@@ -0,0 +1 @@
+*.cis
-- 
1.6.3.1

