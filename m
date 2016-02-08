From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Mon, 08 Feb 2016 14:50:38 +0000
Message-ID: <yw1xzivbdznl.fsf@unicorn.mansr.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>
	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>
	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>
	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>
	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net>
	<yw1xbn7vgoux.fsf@unicorn.mansr.com> <56B86F44.3030806@laposte.net>
	<yw1xfux3fhmq.fsf@unicorn.mansr.com> <56B8A6F5.9060409@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B8A6F5.9060409@laposte.net> (Sebastian Frias's message of
	"Mon, 08 Feb 2016 15:32:21 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

>>> By the way, I know some people like the command line, email, etc. b=
ut
>>> there ought to be other tools better suited for patch review...
>>
>> Some kernel subsystems use http://patchwork.ozlabs.org/ to track sta=
tus
>> of various patches.
>>
>
> Thanks, I see that netdev is part of it, and that the patches are the=
re:
>
> https://patchwork.ozlabs.org/patch/580217/
>
> seems like a slight layer over plain email and mailinglists; I was
> thinking of something more in the line of
> https://www.gerritcodereview.com/
> I believe Google uses Gerrit for Android.
> I think Gerrit would probably be too big (and being written in Java,
> using Prolog and other DSLs, implementing its own Git server in Java,
> etc, may make some -or lots?- of kernel developers cry :-) )
> However, in Gerrit it is easier to know where in the "review" process
> we are, because people have to explicitly give a score "+/- X" when
> commenting on a patch.
> Also, the diff can operate between different versions of the patches
> themselves to see if the inlined comments were addressed.

Gerrit has some merits, but for seasoned developers it's largely a
nuisance.  It's probably good at keeping junior/undisciplined developer=
s
from doing too much damage by strictly enforcing a cumbersome process.

--=20
M=E5ns Rullg=E5rd
