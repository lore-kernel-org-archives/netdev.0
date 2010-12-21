From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 11:44:29 +0100
Message-ID: <1292928269.2720.0.camel@edumazet-laptop>
References: <1292886976.2627.146.camel@edumazet-laptop>
	 <20101221101506.GA8149@ff.dom.local>  <20101221103026.GA8622@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56645 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058Ab0LUKoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 05:44:34 -0500
Received: by wwa36 with SMTP id 36so3981597wwa.1
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 02:44:33 -0800 (PST)
In-Reply-To: <20101221103026.GA8622@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 10:30 +0000, Jarek Poplawski a =C3=
=A9crit :
> On Tue, Dec 21, 2010 at 10:15:06AM +0000, Jarek Poplawski wrote:
> > The change of allotment limit looks OK [...]
>=20
> Hmm... but maybe s/ALLOT_ZERO/SFQ_ALLOT_ZERO/? ;-)

Its a local symbol, its not like it being in an include file ;)


