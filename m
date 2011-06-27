From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 08:05:57 +0200
Message-ID: <1309154757.2532.70.camel@edumazet-laptop>
References: <913f4373-e01f-4aa9-b8c7-d041d70f0945@exht1.ad.emulex.com>
	 <1308911520.2228.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110624.125905.362177986003856504.davem@davemloft.net>
	 <3367B80B08154D42A3B2BC708B5D41F63F188EE7A3@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42527 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702Ab1F0GGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 02:06:06 -0400
Received: by wwe5 with SMTP id 5so4434398wwe.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 23:06:05 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63F188EE7A3@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 juin 2011 =C3=A0 22:19 -0700, Sathya.Perla@Emulex.Com a
=C3=A9crit :
> >-----Original Message-----
> >From: David Miller [mailto:davem@davemloft.net]
> >Sent: Saturday, June 25, 2011 1:29 AM
> >To: eric.dumazet@gmail.com
> >Cc: Perla, Sathya; netdev@vger.kernel.org
> >Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_updat=
e
> >
> >From: Eric Dumazet <eric.dumazet@gmail.com>
> >Date: Fri, 24 Jun 2011 12:32:00 +0200
> >
> >> Hmm, isnt it a patch I provided 10 days ago ?
> >>
> >> I find very strange so few people are able to properly attribute w=
ork
> >> today...
> >
> >Sathya, if this patch is almost entriely the same as Eric's patch,
> >and you only made small minor changes, then it isn't your work.
>=20
> Dave, Sure, I'm fine with that. Could you apply this patch by replaci=
ng
> my name with Eric's? Or should I do the same and send you another one=
=2E..

Please resend the patch, I am fine with you being the committer, but
please add in Changelog _some_ attribution, like :

Problem initialy reported and fixed by Eric Dumazet.

You see, there is a difference if you at least acknowledge fact that
someone spent some time before you on the problem.

Correct attribution is an incent for people to look at your drivers and
fix their bugs, its a win-win.



