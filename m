From: Petr Vorel <pvorel@suse.cz>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Mon, 27 Feb 2017 08:55:36 +0100
Message-ID: <20170227075535.kohmkiiys7nzeesp@dell5510>
References: <20170224101312.31538-1-pvorel@suse.cz>
 <20170224102926.102b858f@xeon-e3>
Reply-To: Petr Vorel <pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mathias Nyman <m.nyman@iki.fi>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39741 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751540AbdB0IKj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 03:10:39 -0500
Content-Disposition: inline
In-Reply-To: <20170224102926.102b858f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> This really needs to be standardized with some convention. So that ls, grep, git
> all behave the same and done by some standard library.

> The current method is hack that keeps on growing.

It would be easier, if the code could be adapted by some broadly used library, than start
new project for it. But, as there is probably no suitable existing library, it would have
to be a new one.


Kind regards,
Petr
