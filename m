From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sch_sfb
Date: Fri, 14 Jan 2011 16:09:03 +0100
Message-ID: <1295017743.3937.57.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <20110103095842.7677130d@nehalam>
	 <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk> <4D2EE708.8010806@trash.net>
	 <87bp3kg58i.fsf_-_@trurl.pps.jussieu.fr> <4D2F4B83.6060001@trash.net>
	 <7ir5cgs3k1.fsf@lanthane.pps.jussieu.fr> <4D2FA949.8020701@trash.net>
	 <7ivd1rsj6n.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34672 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab1ANPJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 10:09:08 -0500
Received: by wyb28 with SMTP id 28so2914176wyb.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 07:09:07 -0800 (PST)
In-Reply-To: <7ivd1rsj6n.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 14:34 +0100, Juliusz Chroboczek a =C3=
=A9crit :
> > I just looked at it out of interest after already having started my
> > own version.
>=20
> >>   http://thread.gmane.org/gmane.linux.network/90225
> >>   http://thread.gmane.org/gmane.linux.network/90375
>=20
> >> It was reviewed in particular by one Patrick McHardy.
>=20
> > There's no reason to be pissed
>=20
> Yes, there is.
>=20
> First you object to my patch by making a bunch of unreasonable reques=
ts
> (notably that I use the in-kernel classifiers, which are not usable w=
ith
> Bloom filters).  Then it turns out you're implementing your own versi=
on
> "from scratch".  And then you claim that you never saw my version in =
the
> first place?
>=20
> Patrick, what you're doing is not merely rude, it's actually unethica=
l.
>=20

Juliusz, I believe you overreact on this one.

Patrick reviews are really good and very reasonable. Yet, for a beginne=
r
it might sounds difficult to understand and make the requested changes.

I sent you a private mail 2 weeks ago to offer my services to take SFB
and get it into kernel, because I read your previous attempts and
understood you had litle time to make the needed changes.

I got distracted by SFQ/CHOKe experiments but was about to work on SFB
when Patrick sent his mail. I really think we should work together, and
eventually offer SFB as a new qdisc to network admins :)

Thanks !


