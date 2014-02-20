From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: SMP Affinity and 3.12.7
Date: Thu, 20 Feb 2014 22:38:21 +0100
Message-ID: <35f89f3ea93e66799bea831619a0ddb5@justnet.pl>
References: <8f0f9783b81bab41bc19c2cae8f4fec1@justnet.pl>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:58357 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbaBTViH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 16:38:07 -0500
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1WGbK1-0001yU-64
	for netdev@vger.kernel.org; Thu, 20 Feb 2014 22:38:21 +0100
In-Reply-To: <8f0f9783b81bab41bc19c2cae8f4fec1@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Can anyone help, or point the way what could be causing this?

Kernel error http://wklej.org/id/1238075/

---

Thanks,
Adam N.

W dniu 10.02.2014 10:18, Nie=C5=9Bcierowicz Adam napisa=C5=82(a):

> Hi,
> i use 3.12.7 kernel when i set smp_affinity for network device kernel=
=20
> hangs.
> SMP Affinity
> ---
> CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7
> 67: 826 810 3962750 3962737 729 649 729 744 PCI-MSI-edge eth1
> 70: 4430 4476 4411 4431 4500 4466 3706636 3706649 PCI-MSI-edge eth4
>=20
> --
>=20
> My network device
> ---
> 05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit=20
> Ethernet Controller (Copper) (rev 01)
> 05:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit=20
> Ethernet Controller (Copper) (rev 01)
> 0a:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethern=
et=20
> Controller (Copper) (rev 06)
> 0a:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethern=
et=20
> Controller (Copper) (rev 06)
> 0b:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethern=
et=20
> Controller (Copper) (rev 06)
> 0b:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethern=
et=20
> Controller (Copper) (rev 06)
> ---
>=20
> Can anyone help?
>=20
> ---
> Thanks,
> Adam N.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html [1]


Links:
------
[1] http://vger.kernel.org/majordomo-info.html
