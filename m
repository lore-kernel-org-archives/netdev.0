From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 and region #2 not an MMIO resource
Date: Wed, 1 Nov 2006 23:00:36 +0100
Message-ID: <20061101220036.GA3260@electric-eye.fr.zoreil.com>
References: <200611012221.46981.libor.klepac@bcom.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:29316 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1752498AbWKAWEE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 17:04:04 -0500
To: Libor =?utf-8?B?S2xlcMOhxI0=?= <libor.klepac@bcom.cz>
Content-Disposition: inline
In-Reply-To: <200611012221.46981.libor.klepac@bcom.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Libor Klep=C3=A1=C4=8D <libor.klepac@bcom.cz> :
[...]
> i have build computer with msi MS-7235 motherboard, it has r8169 chip=
 onboard
> i'm using kernel version 2.6.18 from debian (and i also rebuild kerne=
l without=20
> NAPI).
> When i modprobe module , dmesg says
>=20
> r8169 Gigabit Ethernet driver 2.2LK loaded
> PCI: Enabling device 0000:03:06.0 (0000 -> 0003)
> ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 21 (level, low) -> IRQ 201
> r8169 0000:03:06.0: region #2 not an MMIO resource, aborting
>=20
> lspci says (there is no region 2? )

Please send lspci -vvx, I need the hexadecimal ID.

--=20
Ueimor
