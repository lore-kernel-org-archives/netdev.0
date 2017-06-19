From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: fixed typo in usage text.
Date: Mon, 19 Jun 2017 15:52:25 -0400
Message-ID: <1497901945-25508-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35109 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdFSTwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 15:52:40 -0400
Received: by mail-io0-f195.google.com with SMTP id f79so12440200ioi.2
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 12:52:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 tc/f_u32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index ff700e9..b272c2c 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -34,7 +34,7 @@ static void explain(void)
 		"Usage: ... u32 [ match SELECTOR ... ] [ link HTID ] [ classid CLASSID ]\n"
 		"               [ action ACTION_SPEC ] [ offset OFFSET_SPEC ]\n"
 		"               [ ht HTID ] [ hashkey HASHKEY_SPEC ]\n"
-		"               [ sample SAMPLE ] [skip-hw | skip-sw]\n"
+		"               [ sample SAMPLE ] [skip_hw | skip_sw]\n"
 		"or         u32 divisor DIVISOR\n"
 		"\n"
 		"Where: SELECTOR := SAMPLE SAMPLE ...\n"
-- 
1.9.1
