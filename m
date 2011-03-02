From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 12:17:47 +0100
Message-ID: <1299064667.2920.4.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61386 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab1CBLRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 06:17:53 -0500
Received: by bwz15 with SMTP id 15so47216bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 03:17:52 -0800 (PST)
In-Reply-To: <20110302020610.GD1005@gandalf.sssup.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 03:06 +0100, Fabio Checconi a =C3=A9cri=
t :
> Hi,
>=20
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Mon, Feb 28, 2011 05:17:38PM -0800
> >
> > This is an implementation of the Quick Fair Queue scheduler develop=
ed
> > by Fabio Checconi. The same algorithm is already implemented in ipf=
w
> > in FreeBSD. Fabio had an earlier version developed on Linux, I just
> > cleaned it up and tested it. All bugs are mine.
> >=20
>=20
>   thanks for posting, I'm pretty sure that bugs are more likely to be
> ours than yours :)
>=20
> During the development of the algorithm we used a simple traffic
> simulator to verify (informally) the timestamping and the guarantees
> provided.  I've tested this version of the code with the simulator an=
d
> so far it worked fine, so I think that timestamping and guarantees sh=
ould
> be OK.
>=20
> Please let us know if we can be of any help,
> fabio

Hmm, I tried to setup QFQ (using iproute2patch
http://patchwork.ozlabs.org/patch/77902/ ) but failed

Do you have a link to a script/sample ?

Thanks


