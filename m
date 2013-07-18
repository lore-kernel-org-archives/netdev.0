From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Wed, 17 Jul 2013 18:55:04 -0700
Message-ID: <1374112504.7622.49.camel@envy.home>
References: <20130716025954.GC26761@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28538 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757723Ab3GRBzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jul 2013 21:55:07 -0400
In-Reply-To: <20130716025954.GC26761@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-15 at 22:59 -0400, Paul Gortmaker wrote:

>    IMPORTANT:  Do not send new net-next content to netdev during the
>    period during which net-next tree is closed.
> 
>    Shortly after the two weeks have passed, (and vX.Y-rc1 is released) the
>    tree for net-next reopens to collect content for the next (vX.Y+1) release.

So I misunderstood this line apparently. I checked Linus tree:

$ git show v3.11-rc1
tag v3.11-rc1
Tagger: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun Jul 14 15:18:41 2013 -0700

Linux 3.11-rc1

And seeing that rc1 had been tagged 3 days ago, submitted the pch_gbe
patch for MinnowBoard to netdev for net-next. David *very* politely :-)
asked me to resubmit when the net-next tree was open. It appears to me
then that we need to add a bit here about searching the archives
mentioned above for the last netdev-is-open message (I presume there is
a common subject format) to know whether a patch will be welcomed or
not.

I am not subscribed to netdev as I contribute only very rarely. Is it
considered a requirement that one be subscribed to netdev in order to
contribute? If so, we should add that here as well.


-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
