From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 10/22] [RFC] trivial: fix typos concerning "function"
Date: Tue, 26 Oct 2010 21:57:07 +0200
Message-ID: <1288123039-22368-10-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1288123039-22368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39469 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759517Ab0JZT5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:57:30 -0400
In-Reply-To: <1288123039-22368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm a bit unsure about this patch.  I'm unable to parse both statements=
=2E

Cc: netdev@vger.kernel.org
Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/isdn/hisax/isar.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index 40b914b..2e72227 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -1427,8 +1427,8 @@ modeisar(struct BCState *bcs, int mode, int bc)
 					&bcs->hw.isar.reg->Flags))
 					bcs->hw.isar.dpath =3D 1;
 				else {
-					printk(KERN_WARNING"isar modeisar analog funktions only with DP1\=
n");
-					debugl1(cs, "isar modeisar analog funktions only with DP1");
+					printk(KERN_WARNING"isar modeisar analog functions only with DP1\=
n");
+					debugl1(cs, "isar modeisar analog functions only with DP1");
 					return(1);
 				}
 				break;
--=20
1.7.2.3

