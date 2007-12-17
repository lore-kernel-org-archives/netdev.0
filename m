From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/sched/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:36 -0800
Message-ID: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe__19286.8385151543$1197922016$gmane$org@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936742AbXLQUGL@vger.kernel.org>
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sched/sch_hfsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 55e7e45..a6ad491 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -160,7 +160,7 @@ struct hfsc_class
 	u64	cl_vtoff;		/* inter-period cumulative vt offset */
 	u64	cl_cvtmax;		/* max child's vt in the last period */
 	u64	cl_cvtoff;		/* cumulative cvtmax of all periods */
-	u64	cl_pcvtoff;		/* parent's cvtoff at initalization
+	u64	cl_pcvtoff;		/* parent's cvtoff at initialization
 					   time */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
-- 
1.5.3.7.949.g2221a6

