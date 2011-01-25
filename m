From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: speedup fragmented skbs
Date: Tue, 25 Jan 2011 22:36:52 +0100
Message-ID: <1295991412.2633.12.camel@edumazet-laptop>
References: <1295975635.3588.337.camel@edumazet-laptop>
	 <20110125.132626.39178379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32818 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880Ab1AYVg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 16:36:58 -0500
Received: by wwa36 with SMTP id 36so285353wwa.1
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 13:36:56 -0800 (PST)
In-Reply-To: <20110125.132626.39178379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 janvier 2011 =C3=A0 13:26 -0800, David Miller a =C3=A9crit =
:

> Applied, although I changed "->page =3D 0;" to "->page =3D NULL;"
>=20

Ok, thanks !


