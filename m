From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] net: dsa: introduce STPID switch
	tagging handling code
Date: Tue, 10 Aug 2010 13:04:12 -0400
Message-ID: <AANLkTinAdmy5RWoPZqJXmO42OS2HWA3wS7MuhFifJUrD@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<20100721150251.GL21121@mail.wantstofly.org> <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com>
	<20100721153531.GN21121@mail.wantstofly.org> <AANLkTinPtd2xXzq0MpR517OsbZWUZjdp25x8FndhQ2CP@mail.gmail.com>
	<AANLkTinNiE1BE=HuwVG2Tom922XJXxQDB-JMsPYimPTk@mail.gmail.com>
	<20100810140552.GV8876@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38985 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab0HJREd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 13:04:33 -0400
Received: by eya25 with SMTP id 25so3939384eya.19
        for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 10:04:32 -0700 (PDT)
In-Reply-To: <20100810140552.GV8876@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 10:05, Lennert Buytenhek wrote:
> Is the hardware you're doing this on available somewhere for me to
> try things out on?

yes & no.  the board in question is here (that picture has two ethernet ports):
http://www.analog.com/en/embedded-processing-dsp/blackfin/BF518-EZBRD/processors/product.html

but that was the first few revs of the board ... later ones have
dropped the switch because it didnt support PTP packets.  i dont think
you can specify "give me an older rev" when ordering from ADI.

if you're interested, i can probably find you an older one laying
around if you're interested in testing things.
-mike
