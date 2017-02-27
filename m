From: Petr Vorel <pvorel@suse.cz>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Mon, 27 Feb 2017 09:57:45 +0100
Message-ID: <20170227085745.oee6pvidb7j52cmm@dell5510>
References: <20170224101312.31538-1-pvorel@suse.cz>
 <20170225172958.GA26279@iki.fi>
Reply-To: Petr Vorel <pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Yegor Yefremov <yegorslists@googlemail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43122 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751625AbdB0JQi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 04:16:38 -0500
Content-Disposition: inline
In-Reply-To: <20170225172958.GA26279@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Yea, I admit, the original color palette is kind of horrendous. I
> wouldn't say the current colors are suitable for a light background
> either.

> I propose you just replace the current colors with their bold
> variants, and leave the background hue guessing out all together. That
> would be an all-round improvement for everyone.
Well, I agree that original colors aren't the best ones for a light background either, but
not all bold variants are suitable for light background - yellow, white and cyan are
problematic at least on some terminals with light background (e.g. konsole; white isn't
used). So I'd really keep separate sets of colors.

> I'll include some comments on this patch-set anyway, as I had a look
> at it.
Thanks for your review, I'll post fixed version with two sets of colors.


Kind regards,
Petr
