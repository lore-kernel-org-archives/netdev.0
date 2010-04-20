From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: cleanups
Date: Tue, 20 Apr 2010 01:18:21 -0700 (PDT)
Message-ID: <20100420.011821.48474107.davem@davemloft.net>
References: <1271689653.3845.73.camel@edumazet-laptop>
	<20100419.132158.143863746.davem@davemloft.net>
	<1271747834.3845.206.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566Ab0DTISQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 04:18:16 -0400
In-Reply-To: <1271747834.3845.206.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 09:17:14 +0200

> Le lundi 19 avril 2010 =E0 13:21 -0700, David Miller a =E9crit :
>=20
>>=20
>> It is getting increasingly complicated to follow who enables and
>> disabled local cpu irqs in these code paths.  We could combat
>> this by adding something like "_irq_enable()" to the function
>> names.
>=20
> Yes I agree, we need a general cleanup in this file
>=20
> Thanks David !
>=20
> [PATCH net-next-2.6] rps: cleanups
>=20

Applied.
