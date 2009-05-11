From: Matt Kraai <kraai@ftbfs.org>
Subject: [PATCH] Ignore .cis files
Date: Mon, 11 May 2009 06:20:37 -0700
Message-ID: <1242048037-27392-1-git-send-email-kraai@ftbfs.org>
References: <1241480588-16168-1-git-send-email-kraai@ftbfs.org>
Cc: netdev@vger.kernel.org, Matt Kraai <kraai@ftbfs.org>
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.ftbfs.org ([83.168.236.214]:52050 "EHLO neon.ftbfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525AbZEKNqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 09:46:31 -0400
In-Reply-To: <1241480588-16168-1-git-send-email-kraai@ftbfs.org>
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
1.6.3

