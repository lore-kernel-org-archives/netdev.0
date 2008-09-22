From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 00/11] PhoNet protocols stack v2
Date: Mon, 22 Sep 2008 18:45:54 +0300
Message-ID: <200809221845.54736.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52848 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbYIVPqG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:46:06 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFjkwH026207
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 18:46:03 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=A0=A0=A0=A0=A0=A0=A0=A0Hello,

This patch series is the second attempt at support for PhoNet network p=
rotocol=20
stack in the Linux kernel and trying to address various comments alread=
y=20
received on the mailing list. This protocol is the primary interface to=
 Nokia=20
cellular modem engines. We are integrating it to the Linux kernel in or=
der to=20
support HSPA cellular data connectivity on the Maemo Software platform.

This patchset provides a "raw" datagram protocol as a starting point, a=
nd is=20
based on the current net-next-2.6.

Any comments welcome.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
