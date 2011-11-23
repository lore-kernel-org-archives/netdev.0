From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: Re: cache forver in 3.2.0-rc2-00400-g866d43c ?
Date: Wed, 23 Nov 2011 21:35:55 +0100
Message-ID: <201111232135.55122.a.miskiewicz@gmail.com>
References: <201111231910.37190.a.miskiewicz@gmail.com> <1322073450.2775.2.camel@edumazet-laptop> <1322077447.2775.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35075 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754436Ab1KWUf6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 15:35:58 -0500
Received: by bke11 with SMTP id 11so2036095bke.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 12:35:57 -0800 (PST)
In-Reply-To: <1322077447.2775.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 of November 2011, Eric Dumazet wrote:
> Le mercredi 23 novembre 2011 =C3=A0 19:37 +0100, Eric Dumazet a =C3=A9=
crit :
> > Le mercredi 23 novembre 2011 =C3=A0 19:31 +0100, Arkadiusz Mi=C5=9B=
kiewicz a
> >=20
> > =C3=A9crit :
> > > Mine 00400-g866d43c was after 6fe4c6d466e95d31164f14b1ac4aefb51f0=
f4f82
> > > (which is merge of ipv4: fix redirect handling), so I have it.
> > >=20
> > > (I'm using pure linus git repo)
> >=20
> > OK thanks for this information, I am working on a patch.
>=20
> Please test the following patch, thanks !

Applied and running, results in a few days (since using net A only once=
 per=20
day).

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
