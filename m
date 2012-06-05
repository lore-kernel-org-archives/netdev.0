From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH IPROUTE2] tc: Update manpage
Date: Tue,  5 Jun 2012 10:13:20 -0700
Message-ID: <1338916400-9190-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58272 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab2FERKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 13:10:11 -0400
Received: by dady13 with SMTP id y13so7557933dad.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 10:10:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a reference to fq_codel to the SEE ALSO section.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/tc.8 |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 14a1cd8..5d73c98 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -369,6 +369,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .BR tc-cbq (8),
 .BR tc-choke (8),
 .BR tc-codel (8),
+.BR tc-fq_codel (8),
 .BR tc-drr (8),
 .BR tc-htb (8),
 .BR tc-hfsc (8),
-- 
1.7.0.4
