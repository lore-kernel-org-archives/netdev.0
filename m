From: Yuval Mintz <yuvalm@mellanox.com>
Subject: [PATCH net 1/2] MAINTAINERS: Update Yotam's E-mail
Date: Mon, 30 Oct 2017 11:41:36 +0200
Message-ID: <1509356497-52094-2-git-send-email-yuvalm@mellanox.com>
References: <1509356497-52094-1-git-send-email-yuvalm@mellanox.com>
Cc: mlxsw@mellanox.com, yotam.gi@gmail.com,
        Yuval Mintz <yuvalm@mellanox.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57332 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751794AbdJ3Jmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 05:42:40 -0400
In-Reply-To: <1509356497-52094-1-git-send-email-yuvalm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotam.gi@gmail.com>

For the time being I will be available in my private mail. Update both the
MAINTAINERS file and the individual modules MODULE_AUTHOR directive with
the new address.

Signed-off-by: Yotam Gigi <yotam.gi@gmail.com>
Signed-off-by: Yuval Mintz <yuvalm@mellanox.com>
---
 MAINTAINERS            | 4 ++--
 net/ife/ife.c          | 2 +-
 net/psample/psample.c  | 2 +-
 net/sched/act_sample.c | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3e95dd7..beac4ee 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6677,7 +6677,7 @@ F:	include/net/ieee802154_netdev.h
 F:	Documentation/networking/ieee802154.txt
 
 IFE PROTOCOL
-M:	Yotam Gigi <yotamg@mellanox.com>
+M:	Yotam Gigi <yotam.gi@gmail.com>
 M:	Jamal Hadi Salim <jhs@mojatatu.com>
 F:	net/ife
 F:	include/net/ife.h
@@ -10897,7 +10897,7 @@ S:	Maintained
 F:	drivers/block/ps3vram.c
 
 PSAMPLE PACKET SAMPLING SUPPORT:
-M:	Yotam Gigi <yotamg@mellanox.com>
+M:	Yotam Gigi <yotam.gi@gmail.com>
 S:	Maintained
 F:	net/psample
 F:	include/net/psample.h
diff --git a/net/ife/ife.c b/net/ife/ife.c
index f360341..7d1ec76 100644
--- a/net/ife/ife.c
+++ b/net/ife/ife.c
@@ -137,6 +137,6 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
 
 MODULE_AUTHOR("Jamal Hadi Salim <jhs@mojatatu.com>");
-MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
+MODULE_AUTHOR("Yotam Gigi <yotam.gi@gmail.com>");
 MODULE_DESCRIPTION("Inter-FE LFB action");
 MODULE_LICENSE("GPL");
diff --git a/net/psample/psample.c b/net/psample/psample.c
index 3a6ad0f..64f9562 100644
--- a/net/psample/psample.c
+++ b/net/psample/psample.c
@@ -296,6 +296,6 @@ static void __exit psample_module_exit(void)
 module_init(psample_module_init);
 module_exit(psample_module_exit);
 
-MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
+MODULE_AUTHOR("Yotam Gigi <yotam.gi@gmail.com>");
 MODULE_DESCRIPTION("netlink channel for packet sampling");
 MODULE_LICENSE("GPL v2");
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index a9f9a2cc..8b5abcd 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -271,6 +271,6 @@ static void __exit sample_cleanup_module(void)
 module_init(sample_init_module);
 module_exit(sample_cleanup_module);
 
-MODULE_AUTHOR("Yotam Gigi <yotamg@mellanox.com>");
+MODULE_AUTHOR("Yotam Gigi <yotam.gi@gmail.com>");
 MODULE_DESCRIPTION("Packet sampling action");
 MODULE_LICENSE("GPL v2");
-- 
2.4.3
