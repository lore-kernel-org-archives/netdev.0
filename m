From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 6/7] drivers: isdn: act2000: fix wrongly positioned brace.
Date: Sat,  7 Feb 2015 20:05:28 +0100
Message-ID: <1423335929-24926-7-git-send-email-baspeters93@gmail.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial, but why not? :)

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/act2000/module.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index 889ffcb..9ba98ce 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -19,8 +19,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 
-static unsigned short act2000_isa_ports[] =
-{
+static unsigned short act2000_isa_ports[] = {
 	0x0200, 0x0240, 0x0280, 0x02c0, 0x0300, 0x0340, 0x0380,
 	0xcfe0, 0xcfa0, 0xcf60, 0xcf20, 0xcee0, 0xcea0, 0xce60,
 };
-- 
2.1.0
