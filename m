From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] net: fix a typo in Documentation/networking/scaling.txt
Date: Tue, 27 Sep 2011 18:03:55 +0800
Message-ID: <20110927100354.18039.92505.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 Documentation/networking/scaling.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 58fd741..8ce7c30 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -243,7 +243,7 @@ configured. The number of entries in the global flow table is set through:
 
 The number of entries in the per-queue flow table are set through:
 
- /sys/class/net/<dev>/queues/tx-<n>/rps_flow_cnt
+ /sys/class/net/<dev>/queues/rx-<n>/rps_flow_cnt
 
 == Suggested Configuration
 

