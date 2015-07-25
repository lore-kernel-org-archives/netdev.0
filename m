From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip: replace white-spaces with tabs
Date: Sat, 25 Jul 2015 08:54:53 -0400
Message-ID: <1437828893-5347-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8819 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbbGYMzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 08:55:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace white-spaces with tabs

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ip.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ip.c b/ip/ip.c
index c23de74..78134f9 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -64,7 +64,7 @@ static void usage(void)
 static int do_help(int argc, char **argv)
 {
 	usage();
-        return 0;
+	return 0;
 }
 
 static const struct cmd {
@@ -185,8 +185,8 @@ int main(int argc, char **argv)
 			argv++;
 			if (argc <= 1)
 				usage();
-                        max_flush_loops = atoi(argv[1]);
-                } else if (matches(opt, "-family") == 0) {
+			max_flush_loops = atoi(argv[1]);
+		} else if (matches(opt, "-family") == 0) {
 			argc--;
 			argv++;
 			if (argc <= 1)
-- 
1.8.3.1
