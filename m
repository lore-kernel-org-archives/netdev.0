From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: pppoe server on interface
Date: Mon, 18 Feb 2013 19:16:41 +0100
Message-ID: <099dd9342f0930a08a82adb75ffb42f2@justnet.pl>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:50794 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751218Ab3BRSQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 13:16:50 -0500
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1U7VGb-0004iX-5m
	for netdev@vger.kernel.org; Mon, 18 Feb 2013 19:16:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see the same problem with the dhcp-relay working at the interface=20
eth4 takes questions from eth4.xxx

at what interface i will saw untagged traffic?

W dniu 18.02.2013 13:48, Nie=C5=9Bcierowicz Adam napisa=C5=82(a):

> Hello,
>=20
> recently changed the kernel to 3.6.0, after changing the kernel pppoe=
=20
> server began to see connections listed on the main interface instead =
of=20
> the vlan.
>=20
> On the switch connected to the router, each port has a separate VLAN.=
=20
> before updating the system had no problem taking over pppoe server=20
> session running on the main interface for vlan traffic.
>=20
> eth4 card should not only support traffic untagged traffic?
>=20
> Thanks
