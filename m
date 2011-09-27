From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: ioctl interface for ethernet switch  configuration
Date: Tue, 27 Sep 2011 15:36:01 +0530
Message-ID: <45EE9921DD12714AB1D7B7B9D2FE208B023025DA68BF@dbde03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:42132 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753258Ab1I0KGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 06:06:07 -0400
Received: from dbdp20.itg.ti.com ([172.24.170.38])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id p8RA64Ln014629
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 05:06:06 -0500
Received: from dbde70.ent.ti.com (localhost [127.0.0.1])
	by dbdp20.itg.ti.com (8.13.8/8.13.8) with ESMTP id p8RA63I7022909
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 15:36:03 +0530 (IST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All

I am implementing a network driver for a 3 port Ethernet switch. We hav=
e sorted out the data path for the switch driver. Additionally being a =
switch module, there are lot other configuration options to program the=
 ALE entries and configure forwarding rules. We are considering impleme=
nting these through driver ioctl interface. Are there existing drivers =
that implement these? Is there a standard interface to handle such a re=
quirement?

---
Regards,
Mugunthan V N.=A0
