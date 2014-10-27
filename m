From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip: Add missing '-details' option
Date: Mon, 27 Oct 2014 17:22:58 +0200
Message-ID: <1414423378-30064-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:63999 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbaJ0PcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 11:32:04 -0400
Received: by mail-la0-f46.google.com with SMTP id gi9so6172313lab.33
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 08:32:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip.8 | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 9065b3a..2d42e98 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -59,6 +59,10 @@ appears twice or more, the amount of information increases.
 As a rule, the information is statistics or some time values.
 
 .TP
+.BR "\-d" , " \-details"
+Output more detailed information.
+
+.TP
 .BR "\-l" , " \-loops " <COUNT>
 Specify maximum number of loops the 'ip addr flush' logic
 will attempt before giving up.  The default is 10.
-- 
2.1.0
