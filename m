From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] doc make: Add *.pdf files to the 'clean' target
Date: Sun, 26 Oct 2014 11:52:03 +0200
Message-ID: <1414317123-31193-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:47333 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaJZKBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 06:01:09 -0400
Received: by mail-la0-f50.google.com with SMTP id s18so4463434lam.23
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 03:01:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 doc/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/doc/Makefile b/doc/Makefile
index b92957e..e9c0ff7 100644
--- a/doc/Makefile
+++ b/doc/Makefile
@@ -70,4 +70,4 @@ install:
 	install -m 0644 $(shell echo *.sgml) $(DESTDIR)$(DOCDIR)
 
 clean:
-	rm -f *.aux *.log *.toc $(PSFILES) $(DVIFILES) *.html
+	rm -f *.aux *.log *.toc $(PSFILES) $(DVIFILES) *.html *.pdf
-- 
2.1.0
