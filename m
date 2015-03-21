From: Andrei Maresu <andreimaresu@gmail.com>
Subject: [PATCH] Net: ethernet: rocker: fixed a space coding style issue
Date: Sat, 21 Mar 2015 20:02:40 +0200
Message-ID: <1426960960-31552-1-git-send-email-andreimaresu@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrei Maresu <andreimaresu@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed a space coding style issue found by checkpatch.pl in rocker.c

Signed-off-by: Andrei Maresu <andreimaresu@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9fb6948..d364b12 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -812,7 +812,7 @@ static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
 static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
 				       void *ptr)
 {
-	desc_info->desc->cookie = (uintptr_t) ptr;
+	desc_info->desc->cookie = (uintptr_t)ptr;
 }
 
 static struct rocker_desc_info *
-- 
1.9.1
