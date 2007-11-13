From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:17:23 +0100
Message-ID: <1194977843.6098.18.camel@lappy>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	 <20071113.033946.114918709.davem@davemloft.net>
	 <20071113034916.2556edd7.akpm@linux-foundation.org>
	 <20071113.035824.40509981.davem@davemloft.net>
	 <20071113041259.79c9a8c5.akpm@linux-foundation.org>
	 <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
	 <20071113164650.GA28493@elte.hu>  <4739E3D0.10201@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48567 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042AbXKMSSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 13:18:00 -0500
In-Reply-To: <4739E3D0.10201@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-11-13 at 12:50 -0500, Mark Lord wrote:
> Ingo Molnar wrote:
> >
> > for example git-bisect was godsent. I remember that years ago bisection 
> > of a bug was a very laborous task so that it was only used as a final, 
> > last-ditch approach for really nasty bugs. Today we can autonomouly 
> > bisect build bugs via a simple shell command around "git-bisect run", 
> > without any human interaction! This freed up testing resources 
> ...
> 
> It's only a godsend for the few people who happen to be kernel developers
> and who happen to already use git.
> 
> It's a 540MByte download over a slow link for everyone else.

Oh, common. Leeching CDs is so yesterday. These days some distributions
don't even offer CDs anymore in favour of DVDs.

I'd be amazed if a lot of the testers would still be on slownet, its
impossible to keep up with the latest distros without broadband.


