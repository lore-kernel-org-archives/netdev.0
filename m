From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] bridge: correct the comment for file br_sysfs_br.c
Date: Tue, 06 Aug 2013 08:44:46 +0800
Message-ID: <520046FE.3010305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34143 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3HFAo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 20:44:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so39572pab.21
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 17:44:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


br_sysfs_if.c is for sysfs attributes of bridge ports, while br_sysfs_br.c
is for sysfs attributes of bridge itself. Correct the comment here.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 net/bridge/br_sysfs_br.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 394bb96..3b9637f 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -1,5 +1,5 @@
 /*
- *	Sysfs attributes of bridge ports
+ *	Sysfs attributes of bridge
  *	Linux ethernet bridge
  *
  *	Authors:
-- 
1.7.10.4
