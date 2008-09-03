From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Wed, 3 Sep 2008 16:20:43 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org>
References: <20080903.161341.239039051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49869 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751840AbYICXUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 19:20:47 -0400
In-Reply-To: <20080903.161341.239039051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 3 Sep 2008, David Miller wrote:
> 
> 4) Several iwlwifi fixes:

Are these really regressions?

And if they aren't, why are they here and now?

Are people really so _stupid_ that they think that no fixes ever cause new 
regressions, so that they think that because they are "fixes" they are 
safe?

Please, guys. I complained once about this already. What's so hard to 
understand?

Do development _separately_. Push new development during the merge window. 
Don't do it later. And don't think that just because it's a 'fix', it 
should go upstream asap.

What's so hard to understand about this?

I'll pull this YET AGAIN, but I'm getting really fed up with telling the 
same people the same thing over and over again. It looks like the iwlwifi 
people don't understand what "merge window" means, and thinks that any 
random fix for any random issue should always just be pushed up.

		Linus
