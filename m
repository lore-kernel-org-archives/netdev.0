From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [1/3] gigaset: avoid registering CAPI driver more than once
Date: Tue, 16 Mar 2010 01:23:05 +0100
Message-ID: <201003160123.06089.isdn@linux-pingi.de>
References: <1268664986.25524@pingi> <20100315.142040.58983190.davem@davemloft.net>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tilman@imap.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, hjlipp@web.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:60808 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932779Ab0CPAXO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 20:23:14 -0400
In-Reply-To: <20100315.142040.58983190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Montag, 15. M=E4rz 2010 22:20:40 David Miller wrote:
> Karsten the way you reforward patches does not work.
>=20
> And I've told you about this last time you submitted ISDN patches.
>=20
> You don't add an extra "From: " line in the message body, so when the
> patch gets applied the author gets set to _you_ instead of the person
> who actually wrote the change.
>
Sorry about that.

>=20
> All you're doing is ACK'ing this person's work, so simply reply to th=
e
> patch they posted and with your "Acked-by" line.  This way patchwork
> and friends will figure out the rest when the patch gets integrated
> into the net-2.6 tree.

I tried to use my own patchwork which is feed  by the
ISDN list to learn more about it, unfortunately it does not help for su=
ch=20
issues.

>=20
> By reposting the patches the way you are we're losing information.
>=20
> Add to this the fact that you never have the time to properly take
> care of ISDN patches, and when you do finally "get to it" you make al=
l
> kinds of submission errors.
>=20
> This is not the first time either, it happens over and over again.
> It's incredibly frustrating, especially for me.
I can understand that.
> Please seriously consider handing ISDN maintainership over to someone
> who unlike you 1) has the time and the desire and 2) knows how to
> submit patches properly.  Probably Tilman is the person who most meet=
s
> these criteria based upon what I've seen.
>=20
> Meanwhile, I'm going to apply the original patches as posted by
> Tilman so that the proper authorship gets set.

=46air enough, thanks.

Karsten
- who had really a very bad day

