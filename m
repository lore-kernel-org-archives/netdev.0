From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: QLGE 10Gb ETHERNET - pair P:/M: entries
 properly
Date: Sun, 28 Jun 2009 11:35:19 -0700
Message-ID: <1246214119.13673.19.camel@Joe-Laptop.home>
References: <cover.1246173664.git.joe@perches.com>
	 <86a775a4ef18051cbf116f969e07d8cb36e56b10.1246173681.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1583 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbZF1SfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 14:35:17 -0400
In-Reply-To: <86a775a4ef18051cbf116f969e07d8cb36e56b10.1246173681.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index fa2a16d..57357d4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4766,8 +4766,8 @@ F:	drivers/net/qla3xxx.*
 
 QLOGIC QLGE 10Gb ETHERNET DRIVER
 P:	Ron Mercer
-M:	linux-driver@qlogic.com
 M:	ron.mercer@qlogic.com
+M:	linux-driver@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	drivers/net/qlge/


