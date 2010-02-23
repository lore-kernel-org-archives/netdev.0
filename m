From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH V2 net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Mon, 22 Feb 2010 19:22:29 -0500
Message-ID: <1266884549.2930.57.camel@obelisk.thedillows.org>
References: <1266804176.10646.65.camel@Joe-Laptop.home>
	 <1266808127.10646.77.camel@Joe-Laptop.home>
	 <1266808995.2930.24.camel@obelisk.thedillows.org>
	 <20100222.154306.114398657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:54448 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221Ab0BWAWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 19:22:32 -0500
In-Reply-To: <20100222.154306.114398657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-22 at 15:43 -0800, David Miller wrote:
> Man you are picky :-/  Are you a control freak?

Sometimes, yes. Aren't you? ;)

> You can't even let Joe write his commit comments consistently with the
> ones he is using for all the other similar network driver transmations?

That's fine, I was offering a suggestion on improving the comments that
I felt were in line with messages in the past from you, Ingo, Linus, and
others regarding the quality of commit messages.

> What makes doing the same exact transformations to your favorite
> driver so special that it deserves a specially constructed commit
> message?

I expect Joe to continue to submit high quality patches, and to grow
into larger roles than the already important one he is doing now. He's
doing good work, and he's been easy to work with. I'd just like to see
the commit messages improve beyond giving a bullet list of changes one
could get from a quick scan of the patch -- adding the context and why
of the changes rather than a mechanical listing.

It doesn't matter for this driver, with its minimal user base. And it
may not be worth the effort for the transformation series. But I think
he's going to move into much larger projects and I believe it would be a
good habit to develop.

