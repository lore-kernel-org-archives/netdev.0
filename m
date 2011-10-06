From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH 2/3] iproute2: lnstat - fix typos
Date: Thu,  6 Oct 2011 14:45:33 +0200
Message-ID: <1317905134-23175-3-git-send-email-contyk@redhat.com>
References: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758255Ab1JFMrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 08:47:39 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p96CldSv007748
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 08:47:39 -0400
In-Reply-To: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petr Sabata <contyk@redhat.com>
---
 misc/lnstat.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index 32ab6a4..bd19cc1 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -45,7 +45,7 @@ static struct option opts[] = {
 	{ "file", 1, NULL, 'f' },
 	{ "help", 0, NULL, 'h' },
 	{ "interval", 1, NULL, 'i' },
-	{ "key", 1, NULL, 'k' },
+	{ "keys", 1, NULL, 'k' },
 	{ "subject", 1, NULL, 's' },
 	{ "width", 1, NULL, 'w' },
 };
@@ -61,7 +61,7 @@ static int usage(char *name, int exit_code)
 	fprintf(stderr, "\t-V --version\t\tPrint Version of Program\n");
 	fprintf(stderr, "\t-c --count <count>\t"
 			"Print <count> number of intervals\n");
-	fprintf(stderr, "\t-d --dumpt\t\t"
+	fprintf(stderr, "\t-d --dump\t\t"
 			"Dump list of available files/keys\n");
 	fprintf(stderr, "\t-f --file <file>\tStatistics file to use\n");
 	fprintf(stderr, "\t-h --help\t\tThis help message\n");
-- 
1.7.6.4
