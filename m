From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/44] drivers/net/vxge: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:34 -0800
Message-ID: <e86e79a18106cc38715136bfb2e880b38f5ac764.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/vxge/vxge-main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 813829f..93e80c5 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2062,7 +2062,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 	struct __vxge_hw_device *hldev;
 	u64 reason;
 	enum vxge_hw_status status;
-	struct vxgedev *vdev = (struct vxgedev *) dev_id;;
+	struct vxgedev *vdev = (struct vxgedev *)dev_id;
 
 	vxge_debug_intr(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
-- 
1.7.3.1.g432b3.dirty
