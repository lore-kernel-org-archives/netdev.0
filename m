From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-next: remove useless union keyword
Date: Mon, 17 May 2010 07:23:44 +0200
Message-ID: <1274073824.2299.59.camel@edumazet-laptop>
References: <1274071108-5142-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54039 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab0EQFXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 01:23:49 -0400
Received: by wwi17 with SMTP id 17so248713wwi.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 22:23:48 -0700 (PDT)
In-Reply-To: <1274071108-5142-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 12:38 +0800, Changli Gao a =C3=A9crit :
> remove useless union keyword in rtable, rt6_info and dn_route.
>=20
> Since there is only one member in a union, the union keyword isn't us=
eful.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


