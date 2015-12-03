From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 6/6] MAINTAINERS: add qmi_wwan driver entry
Date: Thu,  3 Dec 2015 19:24:23 +0100
Message-ID: <1449167063-22703-7-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49257 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbbLCSZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:11 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 MAINTAINERS | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea1751283b49..e9d444a88e48 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11159,6 +11159,13 @@ L:	linux-usb@vger.kernel.org
 S:	Supported
 F:	drivers/usb/class/usblp.c
=20
+USB QMI WWAN NETWORK DRIVER
+M:	Bj=C3=B8rn Mork <bjorn@mork.no>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	Documentation/ABI/testing/sysfs-class-net-qmi
+F:	drivers/net/usb/qmi_wwan.c
+
 USB RTL8150 DRIVER
 M:	Petko Manolov <petkan@nucleusys.com>
 L:	linux-usb@vger.kernel.org
--=20
2.1.4
