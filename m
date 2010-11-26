From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Fri, 26 Nov 2010 18:17:46 +0100
Message-ID: <1290791866.2855.263.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <20101124.114534.15255941.davem@davemloft.net>
	 <AANLkTi=8smjJgTXxe7vj8AHAMceLUr25KurZbm07vP1j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45622 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0KZRRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 12:17:51 -0500
Received: by wyb28 with SMTP id 28so2169280wyb.19
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 09:17:50 -0800 (PST)
In-Reply-To: <AANLkTi=8smjJgTXxe7vj8AHAMceLUr25KurZbm07vP1j@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 novembre 2010 =C3=A0 09:13 -0800, Tom Herbert a =C3=A9cr=
it :
> > Applied, please consider Eric's feedback about map NUMA node placem=
ent.
>=20
> Yes, I intended to do that.  Also, I was planning to add Changli's
> idea of adding CONFIG_XPS.  Also, I believe the case where CONFIG_RPS
> is not enabled breaks the build, I'll send a fix as soon as possible.
>=20
> Tom

I'll provide a patch as soon as David pushes net-next-2.6, dont worry ;=
)

Thanks !


