From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 23:06:08 +0200
Message-ID: <1319144768.2854.40.camel@edumazet-laptop>
References: <1319141403.2854.17.camel@edumazet-laptop>
	   <CAMaF-rN8K3hDiwwqh_eGQ0nrxskn+7r9Rn_yDJ46aesKR77nbg@mail.gmail.com>
	  <1319143442.2854.26.camel@edumazet-laptop> <4EA0885A.9010009@myri.com>
	 <1319144356.2854.36.camel@edumazet-laptop> <4EA08CCB.8030207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Mason <mason@myri.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62003 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368Ab1JTVGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:06:13 -0400
Received: by wwe6 with SMTP id 6so4777491wwe.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 14:06:12 -0700 (PDT)
In-Reply-To: <4EA08CCB.8030207@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 17:04 -0400, Andrew Gallatin a =C3=A9cr=
it :

> OK, I'm feeling foolish.  I somehow missed the first hunk
> of your patch (some local change made it not apply cleanly, and
> I did not notice that).
>=20
> Yes, your patch is correct.  Sorry for the hassle!
>=20

No worry, thanks a lot for reviewing !

>=20
> Acked-by: Andrew Gallatin <gallatin@myri.com>
