From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000_eth: possible NULL dereference of
 aup->mii_bus->irq in au1000_probe()
Date: Tue, 01 Sep 2009 17:45:40 -0700 (PDT)
Message-ID: <20090901.174540.10005976.davem@davemloft.net>
References: <4A9B8C6F.3040503@gmail.com>
	<200908311439.01781.f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755460AbZIBAp0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 20:45:26 -0400
In-Reply-To: <200908311439.01781.f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 31 Aug 2009 14:38:55 +0200

> Hello Roel,
>=20
> Le lundi 31 ao=FBt 2009 10:40:15, Roel Kluin a =E9crit :
>> aup->mii_bus->irq allocation may fail, prevent a dereference of NULL=
=2E
>=20
> Good catch.
>=20
>>
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
