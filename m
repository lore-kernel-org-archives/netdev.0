From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable 0/7] qmi_wwan: adding a few new devices
Date: Fri, 25 Apr 2014 19:00:27 +0200
Message-ID: <1398445234-26620-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34292 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbaDYRAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 13:00:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding some new and some old QMI devices.  A similar series for
usb-serial support will be posted as well.

These new device ID patches should also go to all maintained stable ker=
nels
where they apply. I believe that should be stable-3.10 and newer.


Bj=C3=B8rn Mork (7):
  net: qmi_wwan: add Sierra Wireless EM7355
  net: qmi_wwan: add Sierra Wireless MC73xx
  net: qmi_wwan: add Sierra Wireless MC7305/MC7355
  net: qmi_wwan: add Olivetti Olicard 500
  net: qmi_wwan: add Alcatel L800MA
  net: qmi_wwan: add a number of CMOTech devices
  net: qmi_wwan: add a number of Dell devices

 drivers/net/usb/qmi_wwan.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

--=20
2.0.0.rc0
