From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Mon, 11 Oct 2010 12:41:37 -0700 (PDT)
Message-ID: <20101011.124137.102555159.davem@davemloft.net>
References: <1286471555.2912.291.camel@edumazet-laptop>
	<20101011.121344.260085789.davem@davemloft.net>
	<1286825929.3218.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47412
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755216Ab0JKTlP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 15:41:15 -0400
In-Reply-To: <1286825929.3218.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 21:38:49 +0200

> Le lundi 11 octobre 2010 =E0 12:13 -0700, David Miller a =E9crit :
>=20
>> Ok, I'm fine with this.
>>=20
>> But could you please get rid of that "#if 0" code block?  The commen=
t
>> is fine and should stay, but the commented out code shouldn't really
>> stay there.
>=20
> Sure, here is second version, against latest net-next-2.6
>=20
> Thanks !
>=20
> [PATCH net-next] net: percpu net_device refcount

Excellent, applied, thanks!
