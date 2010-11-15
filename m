From: Joe Perches <joe@perches.com>
Subject: [PATCH 18/44] drivers/net/cnic.c: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:37 -0800
Message-ID: <950331e47b16c2ad28d73502f30f5a0f017b5493.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cnic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 92bac19..594ca9c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1695,7 +1695,7 @@ static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
 		*work = num;
 		return -EINVAL;
 	}
-	*work = 2 + req2->num_additional_wqes;;
+	*work = 2 + req2->num_additional_wqes;
 
 	l5_cid = req1->iscsi_conn_id;
 	if (l5_cid >= MAX_ISCSI_TBL_SZ)
-- 
1.7.3.1.g432b3.dirty
