From: kaber@trash.net
Subject: [PATCH 68/79] netfilter: xtables: add missing header files to export list
Date: Wed, 19 Jan 2011 20:15:08 +0100
Message-ID: <1295464519-21763-69-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 9f11fbc..fc4e0aa 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -56,6 +56,8 @@ header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
 header-y += xt_sctp.h
+header-y += xt_secmark.h
+header-y += xt_socket.h
 header-y += xt_state.h
 header-y += xt_statistic.h
 header-y += xt_string.h
-- 
1.7.2.3

