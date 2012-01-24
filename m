From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Tue, 24 Jan 2012 16:47:46 +0100
Message-ID: <1327420066.7231.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <1297107597.4077.8.camel@bwh-desktop>
	 <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327419002.5400.27.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59422 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab2AXPrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 10:47:51 -0500
Received: by bkas6 with SMTP id s6so3562189bka.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 07:47:50 -0800 (PST)
In-Reply-To: <1327419002.5400.27.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 janvier 2012 =C3=A0 15:30 +0000, Ben Hutchings a =C3=A9crit=
 :
> On Tue, 2012-01-24 at 14:54 +0100, Eric Dumazet wrote:

> > Hi guys
> >=20
> > Do we have any ethtool patch to use these 'new' features ?
>=20
> I have some unfinished changes to support this.  What I don't want to=
 do
> is to add an entirely separate set of options; I want -k/-K to work w=
ith
> old and new kernel versions, supporting named features as an extensio=
n
> where available.

Excellent !

Thanks
