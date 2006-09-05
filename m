From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH 2/2] tcp-lp: update information to MAINTAINERS
Date: Wed, 6 Sep 2006 04:31:43 +0800
Message-ID: <3feffd230609051331p22968e65s20ae69df1b935536@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.207]:7914 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1161048AbWIEUbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 16:31:44 -0400
Received: by nz-out-0102.google.com with SMTP id n1so1146789nzf
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2006 13:31:43 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.18-rc6/MAINTAINERS linux/MAINTAINERS
--- linux-2.6.18-rc6/MAINTAINERS	2006-09-06 04:12:11.000000000 +0800
+++ linux/MAINTAINERS	2006-09-06 04:19:08.000000000 +0800
@@ -2818,6 +2818,14 @@ M:	hadi@cyberus.ca
 L:	netdev@vger.kernel.org
 S:	Maintained

+TCP LOW PRIORITY MODULE
+P:	Wong Hoi Sing, Edison
+M:	hswong3i@gmail.com
+P:	Hung Hing Lun, Mike
+M:	hlhung3i@gmail.com
+W:	http://tcp-lp-mod.sourceforge.net/
+S:	Maintained
+
 TI OMAP RANDOM NUMBER GENERATOR SUPPORT
 P:	Deepak Saxena
 M:	dsaxena@plexity.net
