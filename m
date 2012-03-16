From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] wimax/i2400m: fix erroneous NETDEV_TX_BUSY use
Date: Fri, 16 Mar 2012 07:17:53 -0700
Message-ID: <1331907473.2420.2.camel@edumazet-laptop>
References: <1331752904.6022.53.camel@edumazet-glaptop>
	 <20120316.020246.792440183234503872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57114 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758857Ab2CPORz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 10:17:55 -0400
Received: by dajr28 with SMTP id r28so6200424daj.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 07:17:54 -0700 (PDT)
In-Reply-To: <20120316.020246.792440183234503872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 mars 2012 =C3=A0 02:02 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> Applied, but Eric:
>=20
> > @@ -367,38 +367,28 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_=
buff
> > *skb,
>=20
> Your mailer chopped up that line and I had to fix it up.

Oh sorry, thanks for taking care of this David.
