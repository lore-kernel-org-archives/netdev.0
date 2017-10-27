From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] ip: added missing newline in man page
Date: Fri, 27 Oct 2017 15:05:34 -0400
Message-ID: <1509131134-25531-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:47286 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932354AbdJ0TFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 15:05:40 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so14805188ioi.4
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 12:05:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/ip-link.8.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 851b308..d96ee28 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -250,6 +250,7 @@ Link types:
 .sp
 .B bond
 - Bonding device
+.sp
 .B can
 - Controller Area Network interface
 .sp
-- 
1.9.1
