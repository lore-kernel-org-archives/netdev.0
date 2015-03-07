From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add short description about 'group'
Date: Sat,  7 Mar 2015 15:43:37 +0200
Message-ID: <1425735817-13511-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:42452 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbbCGNzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 08:55:11 -0500
Received: by lams18 with SMTP id s18so890835lam.9
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 05:55:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index be4b481..9bbf2d3 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -841,6 +841,12 @@ print human readable rates in IEC units (ie. 1K = 1024).
 .I "TYPE"
 specifies which help of link type to dislpay.
 
+.SS
+.I GROUP
+may be a number or a string from the file
+.B /etc/iproute2/group
+which can be manually filled.
+
 .SH "EXAMPLES"
 .PP
 ip link show
-- 
2.3.1
