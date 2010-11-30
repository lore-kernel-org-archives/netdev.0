From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/8] inetpeer for ipv6, take 2
Date: Tue, 30 Nov 2010 23:17:10 +0100
Message-ID: <1291155430.2856.33.camel@edumazet-laptop>
References: <20101130.132152.260110265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58133 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab0K3WRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:17:15 -0500
Received: by wwa36 with SMTP id 36so6601882wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 14:17:13 -0800 (PST)
In-Reply-To: <20101130.132152.260110265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 13:21 -0800, David Miller a =C3=A9crit=
 :
> Ok, this time, thanks to feedback from Eric Dumazet and others,
> I've taken a more systematic approach to these changes.
>=20
> Now there are two seperate AVL trees for ipv4 and ipv6.
>=20
> Looking further, I've considered a dumping facility for these
> things as currently there is no real way to monitor these
> tables and we surely will want to if inetpeer takes on more
> responsibilities.


I reviewed your patches and they look very good !

Its a bit late here for a compile/boot test...


