From: Aleksander Morgado <aleksander@lanedo.com>
Subject: [PATCH] net: qmi_wwan: new device: Foxconn/Novatel E396
Date: Tue, 28 Aug 2012 14:30:32 +0200
Message-ID: <1346157032-31742-1-git-send-email-aleksander@lanedo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Aleksander Morgado <aleksander@lanedo.com>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Ben Chan <benchan@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanedo.com ([85.214.136.179]:35726 "EHLO lanedo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002Ab2H1Mia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 08:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46oxconn-branded Novatel E396, Gobi3k modem.

Cc: Dan Williams <dcbw@redhat.com>
Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Cc: Ben Chan <benchan@google.com>
Signed-off-by: Aleksander Morgado <aleksander@lanedo.com>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 328397c..189e52d 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -441,6 +441,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
 	{QMI_GOBI_DEVICE(0x1199, 0x901b)},	/* Sierra Wireless MC7770 */
+	{QMI_GOBI_DEVICE(0x1410, 0xa021)},	/* Foxconn Gobi 3000 Modem device =
(Novatel E396) */
=20
 	{ }					/* END */
 };
--=20
1.7.11.4
