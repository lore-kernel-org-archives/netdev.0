From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment
 bsockets and num_owners
Date: Fri, 26 Nov 2010 09:23:21 +0100
Message-ID: <1290759801.2855.5.camel@edumazet-laptop>
References: <341722.22818.qm@web53703.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37907 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab0KZIX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 03:23:26 -0500
Received: by wyb28 with SMTP id 28so1676911wyb.19
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 00:23:25 -0800 (PST)
In-Reply-To: <341722.22818.qm@web53703.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 23:49 -0800, Nagendra Tomar a =C3=A9cr=
it :
>=20
> --- On Fri, 26/11/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> >=20
> > Interesting, how did you notice it is wrong ?
> >=20
>=20
> Bumped on it while reading related code.=20
>=20
>=20
>      =20


OK so you'll have to make a proof, because current code seems to work ;=
)



