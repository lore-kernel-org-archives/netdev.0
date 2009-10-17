From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: MAINTAINERS drivers/net cleanups?
Date: Sat, 17 Oct 2009 12:55:50 +0200
Message-ID: <m3vdiep9vt.fsf@intrepid.localdomain>
References: <1255729936.2267.179.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53182 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738AbZJQKzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 06:55:49 -0400
In-Reply-To: <1255729936.2267.179.camel@Joe-Laptop.home> (Joe Perches's
	message of "Fri, 16 Oct 2009 14:52:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> There are many people described as MAINTAINERS for
> these files that have not had a single sign-off or
> commit in git history.
>
> That's 4+ years.
>
> Here are the files, nominal maintainers, and the
> sections of MAINTAINERS that could be dropped.
>
> Should these individuals be removed from MAINTAINERS
> and added to CREDITS if not already there?

I'm not sure we can do that, esp. with the old ISA drivers. It may just
happen that the drivers are as complete as possible, and occasional
patches resulting from core changes don't necessarily have to be
signed-off-by the maintainer. I don't think we should remove the
MAINTAINERS entries in such cases blindly, at least not before the
driver itself is removed.

How long ago anyone of us used those EExpress, WD8003 or NE2000?
Not this Millennium certainly? :-)

BTW CREDITS is opt-in, isn't it?
-- 
Krzysztof Halasa
