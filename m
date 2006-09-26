From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/4] ethtool: spelling fix
Date: Tue, 26 Sep 2006 13:10:52 -0700
Message-ID: <20060926131052.47877173@freekitty>
References: <20060926115437.11ed1f85@freekitty>
	<451AF4B1.2000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40882 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031183AbWI0WwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:52:19 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451AF4B1.2000208@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix my bogus spelling.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/marvell.c b/marvell.c
index 373ebcf..c44fea3 100644
--- a/marvell.c
+++ b/marvell.c
@@ -68,9 +68,9 @@ static void dump_queue(const char *name,
 	printf("Status                           0x%08X\n", d->status);
 	printf("Timestamp                        0x%08X\n", d->timestamp);
 	if (rx) {
-		printf("Csum1      Offset %4d Positon   %d\n",
+		printf("Csum1      Offset %4d Position  %d\n",
 		       d->csum1, d->csum1_start);
-		printf("Csum2      Offset %4d Positon   %d\n",
+		printf("Csum2      Offset %4d Position  %d\n",
 		       d->csum2, d->csum2_start);
 	} else
 		printf("Csum Start 0x%04X Pos %4d Write %d\n",
-- 
1.4.1

