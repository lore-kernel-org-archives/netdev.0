From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix sock freeing before sock_init_data() with
	__sk_free()
Date: Mon, 31 Aug 2009 07:25:59 +0000
Message-ID: <20090831072559.GD5005@ff.dom.local>
References: <20090830222340.GA17454@ami.dom.local> <4A9B6D23.9090505@gmail.com> <20090831063648.GB5005@ff.dom.local> <4A9B72B1.2040908@gmail.com> <20090831070733.GC5005@ff.dom.local> <4A9B7956.40507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:43188 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbZHaH0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 03:26:02 -0400
Received: by fxm17 with SMTP id 17so2589843fxm.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 00:26:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9B7956.40507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 09:18:46AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On Mon, Aug 31, 2009 at 08:50:25AM +0200, Eric Dumazet wrote:
=2E..
> >> Well, patch is yours, not mine, and I am confident it is OK.
> >=20
> > Well, it's from you, and I guess you'll sign off too, but if you
> > think so...
> > =20
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >=20
> > Thanks,
> > Jarek P.
> >=20
>=20
> Give me a few hours to review sk_alloc() call sites, test patch and o=
fficially submit it.
>=20
> Thanks

Hmm... but you're "confident it is OK"?! (You know, I could've risked
my life or something... ;-)

Jarek P.
