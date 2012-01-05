From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Thu, 5 Jan 2012 17:46:06 +0100
Message-ID: <CACPM=kVeqfxc3SkMPghLOTHFiiVCkPmdRBtVKA_RDfVS3iZOsg@mail.gmail.com>
References: <20111230215024.GA5513@electric-eye.fr.zoreil.com>
	<CACPM=kUxSRhDc2EqgceBRTFgBei7dh3_n7bPyoH=8aNC_uq4FA@mail.gmail.com>
	<20111230221938.GA6197@electric-eye.fr.zoreil.com>
	<CACPM=kXAr46BXAc3t8puRB37NeFy_ZEOWZa0H=DnSioagSLpxA@mail.gmail.com>
	<CACPM=kWn41S85eLgj4G+c6cN0WBgqF=6MigSwa9QBOxD1Uh64A@mail.gmail.com>
	<20111231121710.GB9842@electric-eye.fr.zoreil.com>
	<CACPM=kX2B6p6CSs+s-5WUbQCLa0WZW5K9Rr+hnB5VCxkEmh=8w@mail.gmail.com>
	<20120103223243.GB8563@electric-eye.fr.zoreil.com>
	<CACPM=kUhBydaVDQaxs7BaB_ZkFRa2p6cVme-77Gbsk+QDk=MFA@mail.gmail.com>
	<CACPM=kWL+Z6PH268qg=i0Nafrouq4O25+uFf8WLcE08azqpqpA@mail.gmail.com>
	<20120105162013.GA19440@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105162013.GA19440@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/5 Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> [...]
>> Sorry for repeating myself David, but would it be possible to get th=
is
>> into net-next for 3.4 inclusion ?
>
> You should not expect #net-next for 3.4 to open before the merge wind=
ow
> for 3.3 is closed.

Okay, I'm still pretty new to how the kernel development model works,
and what opens when and for how long, but hey, you learn something
everyday :)

> With due consideration for his freedom of will and action, David can =
not
> take the current patchkit because he needs a formal submission of a c=
omplete
> set where #3 is fixed. Our last friday's exchange does not count as o=
ne.

Sure, it wasn't meant like that (Sorry if it was written that way, can
be difficult from time to time to get it across on paper) :)

> I understand it is important for you, it will be sent, ok ?

Yep :)

/Bjarke

> For future reference, you can see what is going on here :
>
> http://patchwork.ozlabs.org/project/netdev/list/?state=3D*&q=3Dvia-rh=
ine
>
> /me returns to paperwork...
>
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
