From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] ipv6 ip6_tunnel: eliminate unused recursion
 field from ip6_tnl{}.
Date: Wed, 10 Mar 2010 05:48:57 +0100
Message-ID: <1268196537.2872.123.camel@edumazet-laptop>
References: <201003100247.o2A2lqaX001898@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62237 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227Ab0CJEtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 23:49:02 -0500
Received: by bwz1 with SMTP id 1so4610971bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 20:49:00 -0800 (PST)
In-Reply-To: <201003100247.o2A2lqaX001898@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 mars 2010 =C3=A0 11:47 +0900, YOSHIFUJI Hideaki a =C3=A9=
crit :
> Commit a43912ab19... ("tunnel: eliminate recursion field") eliminated
> use of recursion field from tunnel structures, but its definition
> still exists in ip6_tnl{}.
>=20
> Let's remove that unused field.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


