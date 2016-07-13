From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH iproute2-master 2/2] man: Point to 'devlink-sb' from 'devlink' man page
Date: Wed, 13 Jul 2016 09:53:54 +0300
Message-ID: <1468392834-5096-2-git-send-email-idosch@mellanox.com>
References: <1468392834-5096-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0061.outbound.protection.outlook.com ([104.47.2.61]:36928
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752723AbcGMI3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 04:29:41 -0400
In-Reply-To: <1468392834-5096-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 man/man8/devlink.8 | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/man8/devlink.8 b/man/man8/devlink.8
index df00f4f..cf0563b 100644
--- a/man/man8/devlink.8
+++ b/man/man8/devlink.8
@@ -76,6 +76,7 @@ Exit status is 0 if command was successful or a positive integer upon failure.
 .BR devlink-dev (8),
 .BR devlink-port (8),
 .BR devlink-monitor (8),
+.BR devlink-sb (8),
 .br
 
 .SH REPORTING BUGS
-- 
2.8.2
