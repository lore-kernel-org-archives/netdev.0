From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
 online CPUs default
Date: Tue, 23 Mar 2010 12:09:56 -0700 (PDT)
Message-ID: <20100323.120956.121236117.davem@davemloft.net>
References: <1269344306.2983.16.camel@edumazet-laptop>
	<412e6f7f1003230458o459b9e45i7327c5330c43e152@mail.gmail.com>
	<1269349580.2983.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753206Ab0CWTJd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Mar 2010 15:09:33 -0400
In-Reply-To: <1269349580.2983.113.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Mar 2010 14:06:20 +0100

> Le mardi 23 mars 2010 =E0 19:58 +0800, Changli Gao a =E9crit :
>=20
>> The sysadmins you mentioned above are Linux experters, and they know
>> how to tunning the system to get the best performance, but the defau=
lt
>> configuration should be for the ordinary users, who don't know Linux
>> much.
>>=20
>=20
> I strongly NACK your change at this very moment, many devices run
> without a linux expert to tune them, thanks.

Right, we're not GNOME, we don't screw knowledgable users of
our software by default.

I agree with Eric %100 on this.
