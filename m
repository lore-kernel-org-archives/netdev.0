From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 22:05:01 +0200
Message-ID: <1305317101.3120.9.camel@edumazet-laptop>
References: <20110510233540.GJ6397@morgul.net>
	 <20110513125314.66861b31@nehalam> <1305316844.3120.8.camel@edumazet-laptop>
	 <20110513.160232.1127228366429050055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, noahm@debian.org,
	herbert@gondor.hengli.com.au, ben@decadent.org.uk,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45729 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab1EMUFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:05:05 -0400
Received: by wwa36 with SMTP id 36so3227532wwa.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 13:05:04 -0700 (PDT)
In-Reply-To: <20110513.160232.1127228366429050055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 mai 2011 =C3=A0 16:02 -0400, David Miller a =C3=A9crit :

> I do need to queue it up for -stable because the faulty commit is
> also queued up there :-)

okay ;)


