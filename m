From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Tue, 24 May 2011 15:17:49 +0200
Message-ID: <1306243069.3026.34.camel@edumazet-laptop>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
	 <1306153938.20687.2.camel@edumazet-laptop>
	 <1306155058.20687.8.camel@edumazet-laptop>
	 <47b6835144d208dca4c6675f6510fcad@visp.net.lb>
	 <1306163146.20687.19.camel@edumazet-laptop>
	 <d3a37593d507f6e16c4e7cbf121cdd6b@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61236 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105Ab1EXNRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 09:17:53 -0400
Received: by wwa36 with SMTP id 36so7313991wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 06:17:52 -0700 (PDT)
In-Reply-To: <d3a37593d507f6e16c4e7cbf121cdd6b@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 01:35 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :
> On Mon, 23 May 2011 17:05:46 +0200, Eric Dumazet wrote:
> > Le lundi 23 mai 2011 =C3=A0 17:27 +0300, Denys Fedoryshchenko a =C3=
=A9crit :
> >
> >> > Thanks !
> >>  By objdump or he must recompile kernel with DEBUG_INFO and use gd=
b?
> >>
> >>
> >>
> >
> >
> > Just objdump of sch_sfq.o (or sch_sfq.ko) file, (to keep existing
> > offsets), thanks
>  Sorry for delay, i had to contact person who run that kernel :)
>=20
>  www.nuclearcat.com/files/disasm.txt
>  www.nuclearcat.com/files/sch_sfq.ko
>=20
>=20

Thanks !

BTW, does this person have another bug trace to feed us ?

I tried to reproduce it here but failed.

full dmesg might help too=20


