From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [2.6 patch] remove the unused APOLLO_ELPLUS option
Date: Thu, 26 Jun 2008 09:26:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806260925190.30924@anakin>
References: <20080625162454.GB10285@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>,
	linux-m68k@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yorgi.telenet-ops.be ([195.130.133.69]:59491 "EHLO
	yorgi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbYFZH1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 03:27:40 -0400
Received: from monty.telenet-ops.be (monty.telenet-ops.be [195.130.132.56])
	by yorgi.telenet-ops.be (Postfix) with ESMTP id 500F0589B5E
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 09:26:51 +0200 (CEST)
In-Reply-To: <20080625162454.GB10285@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Jun 2008, Adrian Bunk wrote:
> Looking at older kernel sources the APOLLO_ELPLUS option was added 
> somewhere during kernel 2.1, but even kernel 2.2.0 does not contain
> any driver that would be enabled through it...
> 
> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

(queued for 2.6.27, unless Jeff wants it to pass via his tree?)

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
