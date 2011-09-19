From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH Question, Firewall mark inherit for ip6_tunnel
Date: Mon, 19 Sep 2011 11:25:24 +0200
Message-ID: <1316424324.2539.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans =?ISO-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37368 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab1ISJZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 05:25:15 -0400
Received: by bkbzt4 with SMTP id zt4so5139210bkb.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 02:25:14 -0700 (PDT)
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 10:47 +0200, Hans Schillstr=C3=B6m a =
=C3=A9crit :
> Hello Eric,
> For a year ago you send an untested patch to Anders Franzen=20
> I think the subject was "not possible to do policy routing for next h=
op on tunnels."
>=20
> The patch have been used since that and it works perfectly,
> I made some minor changes to reflect the flowi changes.
>=20
> Would it be possible for you to submit that patch, since (I guess) yo=
u are the author=20
> I can prepare it if you want.
> The included patch is for  linux-3.0.4
>=20
> Regards
> Hans Schillstrom

Hello Hans

Yes, I'll respin this patch on top on net-next, with your "Tested-by"
signature ;)

Thanks
