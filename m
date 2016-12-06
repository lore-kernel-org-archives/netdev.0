From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 1/7] irda: w83977af_ir: Whitespace neatening
Date: Tue,  6 Dec 2016 10:16:00 -0800
Message-ID: <b868979fad545faeea6c68fdaba1c48d70a330a2.1481047792.git.joe@perches.com>
References: <cover.1481047792.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1481047792.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove leading and trailing whitespace.
git diff -w shows no differences.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 96745888a4fc..d4b1d74d3081 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -263,7 +263,7 @@ static int w83977af_close(struct w83977af_ir *self)
 {
 	int iobase;
 
-        iobase = self->io.fir_base;
+	iobase = self->io.fir_base;
 
 #ifdef CONFIG_USE_W977_PNP
 	/* enter PnP configuration mode */
-- 
2.10.0.rc2.1.g053435c
