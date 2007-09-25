From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: 25 Sep 2007 16:00:26 +0200
Message-ID: <ygfir5yetfp.fsf@janus.isnogud.escape.de>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122244.15989.5@janus.isnogud.escape.de>
	<20070925.222631.116063075.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	joe@perches.com, tglx@linutronix.de, oliver@hartkopp.net,
	oliver.hartkopp@volkswagen.de
To: YOSHIFUJI Hideaki / =?iso-8859-1?q?=C8=A3=D1=C0?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:39259 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416AbXIYOFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 10:05:51 -0400
In-Reply-To: <20070925.222631.116063075.yoshfuji@linux-ipv6.org>; from
  YOSHIFUJI Hideaki / =?iso-8859-1?q?=C8=A3=D1=C0?= 	 on Tue, 25 Sep 2007
  22:26:31 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =C8=A3=D1=C0  <yoshfuji@linux-ipv6.org> writes:

> I'm not a lawyer, but the following lines:
>=20
> | + * Alternatively, provided that this notice is retained in full, t=
his
>                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> | + * software may be distributed under the terms of the GNU General
> | + * Public License ("GPL") version 2 as distributed in the 'COPYING=
'
> | + * file from the main directory of the linux kernel source.
>=20
> make this whole licence imcompatible with GPL.

I'm no lawyer at all, either.  And also Oliver is not, but he has
carried out the fights with our company lawyers.  Maybe he can say
something about whether we can change this.

> I do think you need to allow people to select GPLv2 only.

The sentence you cite *does* allow distribution under GPLv2 only.  And
I think I have often read the restriction to retain such licences in
full in GPLv2 code.  Is that really incompatible?

urs
