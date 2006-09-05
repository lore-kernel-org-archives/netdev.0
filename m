From: "Edison" <hswong3i@edin.no-ip.com>
Subject: [PATCH 2/2] tcp-lp: update information to MAINTAINERS
Date: Wed, 6 Sep 2006 04:47:42 +0800
Message-ID: <000601c6d12c$883f3dd0$145da8c0@edinws01>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [218.191.238.119] ([218.191.238.119]:39326 "EHLO
	edin-dc.edin.no-ip.com") by vger.kernel.org with ESMTP
	id S1422634AbWIEUrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 16:47:45 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.18-rc6/MAINTAINERS linux/MAINTAINERS
--- linux-2.6.18-rc6/MAINTAINERS        2006-09-06 04:12:11.000000000 +0800
+++ linux/MAINTAINERS   2006-09-06 04:19:08.000000000 +0800
@@ -2818,6 +2818,14 @@ M:       hadi@cyberus.ca
 L:     netdev@vger.kernel.org
 S:     Maintained

+TCP LOW PRIORITY MODULE
+P:     Wong Hoi Sing, Edison
+M:     hswong3i@gmail.com
+P:     Hung Hing Lun, Mike
+M:     hlhung3i@gmail.com
+W:     http://tcp-lp-mod.sourceforge.net/
+S:     Maintained
+
 TI OMAP RANDOM NUMBER GENERATOR SUPPORT
 P:     Deepak Saxena
 M:     dsaxena@plexity.net

