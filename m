From: Joe Perches <joe@perches.com>
Subject: Re: [next][pull request] isdn: Whitespace style reformatting
Date: Mon, 20 Feb 2012 17:29:51 -0800
Message-ID: <1329787791.8318.28.camel@joe2Laptop>
References: <1329712694.30026.42.camel@joe2Laptop>
	 <20120220.193146.55696380871971232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58171 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752023Ab2BUB3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 20:29:51 -0500
In-Reply-To: <20120220.193146.55696380871971232.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-20 at 19:31 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 19 Feb 2012 20:38:14 -0800
> > The following changes since commit 8ac57b29bb947f00cce7c9736589af8ca74d0fa4:
> >   Add linux-next specific files for 20120217 (2012-02-17 16:41:11 +1100)
> > are available in the git repository at:
> >   git://repo.or.cz/linux-2.6/trivial-mods.git 20120219_isdn
> Joe, give me something against net-next that I can really pull
> from, not this thing with all the rest of the linux-next crap
> in it that I cannot pull from.

OK.  I'll do that maybe tonight or tomorrow.

There are some more logical comparisons that could use some tweaking.
I'll add them (and verify the allyesconfig built-in.o's are still
the same) before sending the pull request.
