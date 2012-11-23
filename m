From: Gilboa Davara <gilboad@gmail.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Fri, 23 Nov 2012 14:37:13 +0200
Message-ID: <CAGw18x+z6LgYAUKggZ+ARZ+xxrZ8dMM9YpcNUnDgS2OdQpr1QQ@mail.gmail.com>
References: <50AD1972.5080403@pobox.com>
	<1353529639.26346.164.camel@shinybook.infradead.org>
	<50ADA05B.2000308@pobox.com>
	<20121121.233945.2225341904551631404.davem@davemloft.net>
	<50ADAFB7.7070704@pobox.com>
	<20121122213950.GA8873@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	jasowang@redhat.com, netdev@vger.kernel.org, slacky@cheapnet.it,
	rggjan@gmail.com, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:63238 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab2KWMhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 07:37:14 -0500
Received: by mail-la0-f46.google.com with SMTP id p5so4295172lag.19
        for <netdev@vger.kernel.org>; Fri, 23 Nov 2012 04:37:13 -0800 (PST)
In-Reply-To: <20121122213950.GA8873@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 22, 2012 at 11:39 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> It would be nice if gilboad could give it a try (users Cced).
>

Applied it against 3.6.6.
Seems to be working just fine.

> --
> Ueimor

- Gilboa
