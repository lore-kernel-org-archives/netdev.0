From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [374/2many] MAINTAINERS - PCNET32 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:46:49 -0700
Message-ID: <1186987609.10249.22.camel@localhost>
References: <46bffb4c.nrqicrPs7IJXlgQ0%joe@perches.com>
	 <20070812.233630.00455011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, pcnet32@verizon.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2573 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968072AbXHMGsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:48:02 -0400
In-Reply-To: <20070812.233630.00455011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-08-12 at 23:36 -0700, David Miller wrote:
> Ok, 374 patches is just rediculious.
> 
> So many patches eats up an enormous amount of mailing list resources,
> and for these patches in particular there are few reasons to split
> them up at all.  The fact that the split up landed you at 300+ patches
> is a very good indication of that.

More than ridiculous.  Completely agree.

I tried to send 1 patch over the last couple of days.
Unfortunately, it's > 100KB and disappears into the void.

How about 10 patches or so?

What about maintainer sign offs?

Personally, I don't think it's necessary, but for
the subsystem maintainers like you, if or when the
get_maintainers.pl get integrated into patch
generation mechanisms, you might get more emails.
Perhaps more than you want.

Suggestions?

One good thing by emailing all the listed maintainers,
I've gotten several bounces for invalid addresses.

