From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/6] rhashtable-test: Remove unused TEST_NEXPANDS
Date: Thu, 30 Apr 2015 22:37:40 +0000
Message-ID: <1430433465-6066-2-git-send-email-tgraf@suug.ch>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36104 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbD3Whz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:37:55 -0400
Received: by pdea3 with SMTP id a3so74244504pde.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:37:54 -0700 (PDT)
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index b295754..c60fd5d 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -30,7 +30,6 @@
 #define TEST_HT_SIZE	8
 #define TEST_ENTRIES	2048
 #define TEST_PTR	((void *) 0xdeadbeef)
-#define TEST_NEXPANDS	4
 
 struct test_obj {
 	void			*ptr;
-- 
1.9.3
