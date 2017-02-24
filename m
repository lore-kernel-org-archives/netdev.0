From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Fri, 24 Feb 2017 10:28:17 -0500 (EST)
Message-ID: <20170224.102817.1987967741498252394.davem@davemloft.net>
References: <20170224101312.31538-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.nyman@iki.fi, yegorslists@googlemail.com
To: pvorel@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36318 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbdBXPhc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 10:37:32 -0500
In-Reply-To: <20170224101312.31538-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Vorel <pvorel@suse.cz>
Date: Fri, 24 Feb 2017 11:13:12 +0100

> COLORFGBG environment variable is used to detect dark background.
> 
> Idea and a bit of code is borrowed from Vim, thanks.
> 
> Signed-off-by: Petr Vorel <pvorel@suse.cz>
> ---
> Colors are nice, but the ones chosen aren't suitable for dark background.
> COLORFGBG environment variable is used in some libraries and software (e.g.
> ncurses, Vim). COLORFGBG is set by various terminal emulators (e.g. konsole,
> rxvt and rxvt-unicode).
> 
> Chosen colors are questionable. Best solution would be also allow user to
> redefine colors, like ls does with LS_COLORS or grep with GREP_COLORS. But that
> is maybe overkill.

I think you may have posted this to the wrong mailing list.
