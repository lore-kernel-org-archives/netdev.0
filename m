From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH iproute2] fix typo in ip-xfrm man page, rmd610 -> rmd160
Date: Fri, 23 Dec 2016 14:03:16 +0300
Message-ID: <1482490996-17048-1-git-send-email-alexey.kodanev@oracle.com>
Cc: netdev@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19833 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755808AbcLWK5n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 05:57:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 man/man8/ip-xfrm.8 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 11f7104..a0bbef5 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -477,7 +477,7 @@ Encryption algorithms include
 
 Authentication algorithms include
 .BR digest_null ", " hmac(md5) ", " hmac(sha1) ", " hmac(sha256) ","
-.BR hmac(sha384) ", " hmac(sha512) ", " hmac(rmd610) ", and " xcbc(aes) "."
+.BR hmac(sha384) ", " hmac(sha512) ", " hmac(rmd160) ", and " xcbc(aes) "."
 
 Authenticated encryption with associated data (AEAD) algorithms include
 .BR rfc4106(gcm(aes)) ", " rfc4309(ccm(aes)) ", and " rfc4543(gcm(aes)) "."
-- 
1.7.1
