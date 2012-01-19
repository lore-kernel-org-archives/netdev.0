From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2] netem: Add missing '}' in man page
Date: Thu, 19 Jan 2012 13:17:03 -0800
Message-ID: <1327007823-19826-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:32976 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab2ASVMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 16:12:42 -0500
Received: by iagf6 with SMTP id f6so417976iag.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 13:12:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/tc-netem.8 |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
index e6f2616..873608e 100644
--- a/man/man8/tc-netem.8
+++ b/man/man8/tc-netem.8
@@ -31,6 +31,7 @@ NetEm \- Network Emulator
 .br
 .RB "               " gemodel
 .IR p " [ " r " [ " 1-h " [ " 1-k " ]]]"
+.BR " }"
 
 .IR CORRUPT " := "
 .B corrupt
-- 
1.7.0.4
