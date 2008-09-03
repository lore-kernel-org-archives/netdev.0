From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [GIT]: Networking
Date: Wed, 3 Sep 2008 19:38:26 -0400
Message-ID: <20080903233826.GC21704@tuxdriver.com>
References: <20080903.161341.239039051.davem@davemloft.net> <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48301 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbYICXp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 19:45:29 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 04:20:43PM -0700, Linus Torvalds wrote:
> 
> On Wed, 3 Sep 2008, David Miller wrote:
> > 
> > 4) Several iwlwifi fixes:
> 
> Are these really regressions?
> 
> And if they aren't, why are they here and now?
> 
> Are people really so _stupid_ that they think that no fixes ever cause new 
> regressions, so that they think that because they are "fixes" they are 
> safe?

I can't say for sure which are true regressions and which ones are
merely important fixes for code we changed and broke in the process.
I can say that these patches have been through several rounds of
review both within Intel and (more importantly) in the open on the
wireless mailing list.  We recognize the risks and we believe that
the potential benefits outweigh them.

> Please, guys. I complained once about this already. What's so hard to 
> understand?
> 
> Do development _separately_. Push new development during the merge window. 
> Don't do it later. And don't think that just because it's a 'fix', it 
> should go upstream asap.
> 
> What's so hard to understand about this?

I believe not only that the Intel wireless team is getting this
message but also that the message is being reinforced to them by
certain higher profile community members that are also Intel employees.

> I'll pull this YET AGAIN, but I'm getting really fed up with telling the 
> same people the same thing over and over again. It looks like the iwlwifi 
> people don't understand what "merge window" means, and thinks that any 
> random fix for any random issue should always just be pushed up.

I appreciate your indulgence in this matter, just as I appreciate both
you and the rest of the community reinforcing the messages I have been
trying to communicate to the Intel wireless team about the process.
I think they are getting the message and that we will not need to
revisit this topic again too soon.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
