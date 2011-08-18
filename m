From: Willem de Bruijn <willemb@google.com>
Subject: [patch v2] net: netdev-features.txt update to Documentation/networking/00-INDEX
Date: Thu, 18 Aug 2011 12:44:45 -0400
Message-ID: <4E4D417D.9020806@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:32022 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756070Ab1HRQot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 12:44:49 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7IGim1g001551
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 09:44:48 -0700
Received: from vws7 (vws7.prod.google.com [10.241.21.135])
	by wpaz37.hot.corp.google.com with ESMTP id p7IGiNfa014507
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 09:44:47 -0700
Received: by vws7 with SMTP id 7so2426282vws.21
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 09:44:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update netdev-features.txt entry in 00-INDEX to incorporate
feedback by Micha=C5=82 Miros=C5=82aw.

v2: restored tabs that were inadvertently changed to spaces in v1.
sorry for the error.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/00-INDEX |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/00-INDEX b/Documentation/networki=
ng/00-INDEX
index 811252b..bbce121 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -135,7 +135,7 @@ multiqueue.txt
 netconsole.txt
 	- The network console module netconsole.ko: configuration and notes.
 netdev-features.txt
-	- Network interface "feature mess and how to get out from it alive".
+	- Network interface features API description.
 netdevices.txt
 	- info on network device driver functions exported to the kernel.
 netif-msg.txt
--=20
1.7.3.1


