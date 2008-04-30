From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Wed, 30 Apr 2008 17:38:19 +0200
Message-ID: <BAY103-DAV1299426BC4DEDBC952BD39B2D80@phx.gbl>
References: <E1JrE1V-00082Q-00@gondolin.me.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s18.bay0.hotmail.com ([65.54.246.90]:6193 "EHLO
	bay0-omc1-s18.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756423AbYD3Pmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 11:42:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
> > I know, it is pretty useless this report,
> > but I have nothing more than these bitmaps
> > and the message in the subject :-(
> >
> > http://80.204.235.230/1.jpg
> > http://80.204.235.230/2.jpg
> > http://80.204.235.230/2.jpg
>
> Could you please take a better shot of this crash the next time
> it happens? As it is the right-hand-side of the code section is
> missing which makes it hard to determine where exactly it crashed.
>
> Alternatively send me your xfrm_output.o file (or vmlinux).

I have removed these modules from
the two boxes that are crashing:

sch_sfq
sch_htb
cls_fw

I will wait to see if they are crashing
again without these modules loaded.


