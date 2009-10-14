From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Phonet: basic routing support
Date: Wed, 14 Oct 2009 15:08:43 -0700 (PDT)
Message-ID: <20091014.150843.59514584.davem@davemloft.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060AbZJNWIq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 18:08:46 -0400
In-Reply-To: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Wed, 14 Oct 2009 12:47:34 +0200

>=20
> This patchset provides rudimentary support for routing Phonet packets=
=2E
> Configuration is done with the common rtnetlink infrastructure.
>=20
> This is useful when there is more than one Phonet interface in the sa=
me
> namespace,
> e.g. a serial bus to a cellular modem and a USB gadget function to a =
PC.

Looks good, applied to net-next-2.6, thanks.
