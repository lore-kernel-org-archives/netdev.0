From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: BPF 'JIT' compiler for PPC64
Date: Mon, 18 Jul 2011 22:05:08 +0200
Message-ID: <1311019508.16961.1.camel@edumazet-laptop>
References: <4E23E5C3.1070209@ozlabs.org>
	 <1310978375.5756.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110718.124248.1462465498024218250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: matt@ozlabs.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50528 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1GRUFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 16:05:13 -0400
Received: by wwe5 with SMTP id 5so3515302wwe.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 13:05:12 -0700 (PDT)
In-Reply-To: <20110718.124248.1462465498024218250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 juillet 2011 =C3=A0 12:42 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 18 Jul 2011 10:39:35 +0200
>=20
> > So in PPC SEEN_XREG only is to be set of X is read, not if written.
> >=20
> > So you dont have to set SEEN_XREG bit in this part :
>=20
> Matt, do you want to integrate changes based upon Eric's feedback
> here or do you want me to apply your patch as-is for now?
>=20

This was a really minor point, so Matt feel free to ask an immediate
inclusion ;)



