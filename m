From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next 1/2] iproute2: ip-route.8.in: Add missing '[' before 'pref'
Date: Fri, 25 Dec 2015 11:12:15 +0800
Message-ID: <1451013136-13251-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Xin Long <lucien.xin@gmail.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35191 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbLYDM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 22:12:27 -0500
Received: by mail-pf0-f182.google.com with SMTP id 78so73510252pfw.2
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 19:12:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 man/man8/ip-route.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 72d8d77..5b45bc2 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -128,7 +128,7 @@ replace " } "
 .B  quickack
 .IR BOOL " ] [ "
 .B  congctl
-.IR NAME " ]"
+.IR NAME " ] [ "
 .B  pref
 .IR PREF " ]"
 
-- 
2.4.3
