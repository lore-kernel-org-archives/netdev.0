From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net: use IS_ENABLED(CONFIG_IPV6)
Date: Mon, 12 Dec 2011 16:06:41 -0800
Message-ID: <1323734801.3837.10.camel@joe2Laptop>
References: <4EE32777.2030003@parallels.com>
	 <4EE327CB.4040505@parallels.com> <1323514931.4016.17.camel@edumazet-laptop>
	 <20111210.131555.2025649575447940902.davem@davemloft.net>
	 <1323546511.4016.32.camel@edumazet-laptop>
	 <1323554422.29470.4.camel@joe2Laptop>
	 <1323556174.4016.35.camel@edumazet-laptop>
	 <1323564696.29470.6.camel@joe2Laptop>
	 <1323593575.4016.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:32790 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753554Ab1LMAGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 19:06:43 -0500
In-Reply-To: <1323593575.4016.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-12-11 at 09:52 +0100, Eric Dumazet wrote:
> Le samedi 10 d=C3=A9cembre 2011 =C3=A0 16:51 -0800, Joe Perches a =C3=
=A9crit :
> > On Sat, 2011-12-10 at 23:29 +0100, Eric Dumazet wrote:
> > > Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:00 -0800, Joe Perches a=
 =C3=A9crit :
> > > Are you sure this is equivalent ?
> > I believe so.
> You didnt answer my question or you dont understand your change.
> I wonder why.

I believe "I believe so" is an answer.
Perhaps not a good or in this case perhaps
even an answer with an incorrect result,
but still an answer...

> Point was : IPV6 compiled as a module, and _this_ driver compiled
> staticaly.
> Did you tried this combination ?

No, though I will try it this week.

cheers, Joe
