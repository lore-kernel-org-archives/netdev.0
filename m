From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Thu, 18 Jul 2013 09:33:42 -0400
Message-ID: <51E7EEB6.3080706@windriver.com>
References: <20130716025954.GC26761@windriver.com> <1374112504.7622.49.camel@envy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44675 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759027Ab3GRNdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 09:33:36 -0400
In-Reply-To: <1374112504.7622.49.camel@envy.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-17 09:55 PM, Darren Hart wrote:
> On Mon, 2013-07-15 at 22:59 -0400, Paul Gortmaker wrote:
> 
>>    IMPORTANT:  Do not send new net-next content to netdev during the
>>    period during which net-next tree is closed.
>>
>>    Shortly after the two weeks have passed, (and vX.Y-rc1 is released) the
>>    tree for net-next reopens to collect content for the next (vX.Y+1) release.
> 
> So I misunderstood this line apparently. I checked Linus tree:
> 
> $ git show v3.11-rc1
> tag v3.11-rc1
> Tagger: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Jul 14 15:18:41 2013 -0700
> 
> Linux 3.11-rc1
> 
> And seeing that rc1 had been tagged 3 days ago, submitted the pch_gbe
> patch for MinnowBoard to netdev for net-next. David *very* politely :-)
> asked me to resubmit when the net-next tree was open. It appears to me
> then that we need to add a bit here about searching the archives
> mentioned above for the last netdev-is-open message (I presume there is
> a common subject format) to know whether a patch will be welcomed or
> not.

I will append under the "Shortly after..." text something like:

  "If you aren't subscribed to netdev and/or are simply unsure
  if net-next has re-opened yet, simply check the net-next git
  repository link above for any new networking related commits."

That "link above" would be this:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git

P.
--

> 
> I am not subscribed to netdev as I contribute only very rarely. Is it
> considered a requirement that one be subscribed to netdev in order to
> contribute? If so, we should add that here as well.
> 
> 
