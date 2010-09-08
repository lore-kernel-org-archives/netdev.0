From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: add rehash on connect()
Date: Wed, 08 Sep 2010 17:17:08 +0200
Message-ID: <1283959028.2748.89.camel@edumazet-laptop>
References: <1283895316.2634.248.camel@edumazet-laptop>
	 <4C86F653.6070707@hp.com> <1283921857.2634.747.camel@edumazet-laptop>
	 <20100907.223654.70187707.davem@davemloft.net>
	 <1283925171.2634.838.camel@edumazet-laptop>
	 <1283940646.2880.36.camel@edumazet-laptop>  <4C87A675.6080905@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44496 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525Ab0IHPRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:17:13 -0400
Received: by fxm16 with SMTP id 16so140778fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 08:17:12 -0700 (PDT)
In-Reply-To: <4C87A675.6080905@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 17:06 +0200, Krzysztof Ol=C4=99dzk=
i a =C3=A9crit :

> Thanks, I'll test this patch this evening.

Take the v2 ;)

I tested it on my dev machine and it worked for me.

Thanks


