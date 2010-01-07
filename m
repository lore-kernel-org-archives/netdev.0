From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: make PCI device ids constant
Date: Thu, 07 Jan 2010 00:33:51 -0800 (PST)
Message-ID: <20100107.003351.257169688.davem@davemloft.net>
References: <4B4273A6.4020102@freemail.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, julia@diku.dk,
	cocci@diku.dk
To: nm127@freemail.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932628Ab0AGIdp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 03:33:45 -0500
In-Reply-To: <4B4273A6.4020102@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: N=E9meth M=E1rton <nm127@freemail.hu>
Date: Tue, 05 Jan 2010 00:03:02 +0100

> From: M=E1rton N=E9meth <nm127@freemail.hu>
>=20
> The id_table field of the struct pci_driver is constant in <linux/pci=
=2Eh>
> so it is worth to make pci_device_id also constant.

Applied to net-next-2.6, thank you.
