From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_synack_options() fix
Date: Mon, 17 May 2010 22:35:45 -0700 (PDT)
Message-ID: <20100517.223545.124051499.davem@davemloft.net>
References: <1274072629.2299.58.camel@edumazet-laptop>
	<20100517134240.1949f245@nehalam>
	<1274130278.2567.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, Bijay.Singh@guavus.com, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755598Ab0ERFfg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 01:35:36 -0400
In-Reply-To: <1274130278.2567.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 May 2010 23:04:38 +0200

> Le lundi 17 mai 2010 =E0 13:42 -0700, Stephen Hemminger a =E9crit :
>=20
>> Since you are doing away with flag variable, why not this instead?
>>=20
>=20
> Sure, we can eliminate this doing_ts variable and save few bytes
>=20
> Thanks
>=20
> [PATCH] tcp: tcp_synack_options() fix=20

Applied, thanks!
