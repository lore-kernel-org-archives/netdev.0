From: <rongqing.li@windriver.com>
Subject: [PATCH] net: Documentation: Fix type of variables
Date: Thu, 29 Sep 2011 13:51:54 +0800
Message-ID: <1317275514-12620-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62526 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab1I2Fvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 01:51:54 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca [147.11.189.40])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id p8T5prXN004911
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 22:51:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>


Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 Documentation/networking/ip-sysctl.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 8154699..ca5cdcd 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1042,7 +1042,7 @@ conf/interface/*:
 	The functional behaviour for certain settings is different
 	depending on whether local forwarding is enabled or not.
 
-accept_ra - BOOLEAN
+accept_ra - INTEGER
 	Accept Router Advertisements; autoconfigure using them.
 
 	Possible values are:
@@ -1106,7 +1106,7 @@ dad_transmits - INTEGER
 	The amount of Duplicate Address Detection probes to send.
 	Default: 1
 
-forwarding - BOOLEAN
+forwarding - INTEGER
 	Configure interface-specific Host/Router behaviour.
 
 	Note: It is recommended to have the same setting on all
-- 
1.7.1
