From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Sat, 20 Feb 2016 15:48:58 +0100
Message-ID: <8760xjzbc5.fsf@belgarion.home>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home> <87k2mi4ysn.fsf@belgarion.home>
	<20160205.173021.1388372628450225378.davem@davemloft.net>
	<87fux6439s.fsf@belgarion.home>
	<CAE1WaKK2DqYYOTLmprbLuZVN-8--sZVyZVHgkcT4Jg7797S7HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: g.liakhovetski@gmx.de,
	Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>,
	fabio.estevam@freescale.com,
	Hitoshi Mitake <mitake.hitoshi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp08.smtpout.orange.fr ([80.12.242.130]:17782 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758701AbcBTOtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 09:49:04 -0500
In-Reply-To: <CAE1WaKK2DqYYOTLmprbLuZVN-8--sZVyZVHgkcT4Jg7797S7HQ@mail.gmail.com>
	(Hitoshi Mitake's message of "Mon, 8 Feb 2016 11:03:43 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hitoshi Mitake <mitake.hitoshi@gmail.com> writes:

> Hi Robert,
>
> On Sat, Feb 6, 2016 at 6:05 PM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
>     > Please just keep pinging people to properly test this.
>     
>     Okay, let's have another try.
>     
>     Hi Guennadi, Hitoshi, Fabio,
>     
>     Could any of you try this patch to ensure your board is not broken please ?
>     I've re-added the patch at the end of this mail for easier handling.
>     Normally no
>     code path in non-PXA board is changed, so the test should be
>     straightforward.
>     
>     It's also available in : https://lkml.org/lkml/2015/11/30/768
>     
>     You're the maintainers of the following boards using smc911x AFAIK:
>     - sh2007: Guennadi and Hitoshi
>
> Really sorry, currently I don't have the board :(
> Do you have a working board that can be used for testing, Guennadi?
>
> Thanks,
> Hitoshi

Hello,

I'll reping once more, to see if any of you could give this patch a try.
So far Hitoshi doesn't have the hardware anymore, so it leaves only Guennadi and
Fabio.

If you could give it a try it would be great.

For reference, the patch is here : https://lkml.org/lkml/2015/11/30/768

Cheers.
