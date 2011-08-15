From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH] net: netdev-features.txt update to Documentation/networking/00-INDEX
Date: Mon, 15 Aug 2011 14:27:50 -0400
Message-ID: <4E496526.8090201@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mircus@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:16343 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab1HOS14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 14:27:56 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p7FIRsau025349
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 11:27:54 -0700
Received: from vxh24 (vxh24.prod.google.com [10.241.34.216])
	by hpaq14.eem.corp.google.com with ESMTP id p7FIRrZq029288
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 11:27:53 -0700
Received: by vxh24 with SMTP id 24so4502579vxh.29
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 11:27:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update netdev-features.txt entry in 00-INDEX to incorporate
feedback by Micha=C5=82 Miros=C5=82aw. A trivial update to my previous
patch, but I was too late with preparing a v2. Will try to
avoid having to send patches to my own patches in the future.=20

  willem

Signed-off-by: Willem de Bruijn <willemb@gmail.com>

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
        - The network console module netconsole.ko: configuration and n=
otes.
 netdev-features.txt
-       - Network interface "feature mess and how to get out from it al=
ive".
+       - Network interface features API description.
 netdevices.txt
        - info on network device driver functions exported to the kerne=
l.
 netif-msg.txt
--=20
1.7.3.1

