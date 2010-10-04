From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] caif: remove duplicated include
Date: Mon, 4 Oct 2010 16:35:39 +0200
Message-ID: <20101004163539.5e879211@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove duplicated include.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 net/caif/caif_socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 8ce9047..7a09fb6 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -15,7 +15,6 @@
 #include <linux/poll.h>
 #include <linux/tcp.h>
 #include <linux/uaccess.h>
-#include <linux/mutex.h>
 #include <linux/debugfs.h>
 #include <linux/caif/caif_socket.h>
 #include <asm/atomic.h>
-- 
1.7.2.2
