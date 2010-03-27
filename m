From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/9] drivers/net: Fix continuation lines
Date: Fri, 26 Mar 2010 19:27:55 -0700
Message-ID: <6b7a0c43891d5af5796b681898d901bbf2e1cda1.1269655208.git.joe@perches.com>
References: <cover.1269655208.git.joe@perches.com>
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1269655208.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/atlx/atl1.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9ba5470..0ebd820 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -84,7 +84,7 @@
 
 #define ATLX_DRIVER_VERSION "2.1.3"
 MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
-	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
+Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ATLX_DRIVER_VERSION);
 
-- 
1.7.0.14.g7e948
