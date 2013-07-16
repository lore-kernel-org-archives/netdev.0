From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Tue, 16 Jul 2013 13:35:16 -0700
Message-ID: <1374006916.12825.116.camel@envy.home>
References: <20130716025954.GC26761@windriver.com>
	 <20130716.130514.559781233978406598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60457 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab3GPUfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jul 2013 16:35:17 -0400
In-Reply-To: <20130716.130514.559781233978406598.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 13:05 -0700, David Miller wrote:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 15 Jul 2013 22:59:54 -0400
> 
> > I was wondering if you think there is value in having a netdev-faq type
> > document available -- perhaps as a vger mailout to new subscribers or
> > similar?  For example, I have lost count of the number of times that you
> > have had to tell people that net-next is closed during the merge window.
> > But you would probably be right in telling me that those same people don't
> > read documentation.  Well, that aside, I suppose answering my question
> > is easier when there is a proposed starting point for content.
> > 
> > To that end, I've tried to collect a starting point based on repeated
> > questions/corrections that I've seen over the years.  I've added Greg to
> > the Cc: in order to ensure I've captured the netdev-stable interaction
> > correctly, and I've thrown Darren under the bus as a random content
> > reviewer, since he has expressed an interest in documentation recently.
> > 
> > Below is a possible starting point for content.  Many answers I have
> > written are from memory, long after losing links to netdev threads that
> > served as evidence for the answers, so apologies in advance if I have
> > failed to recall correctly the specific details in which you would like
> > to see things done.
> 
> Thanks a lot for writing this, it is useful.
> 
> I think it's easier if this lives somewhere under
> Documentation/networking in the kernel tree, then we can just point
> people at it.
> 
> What do you think?

Maybe netdev_kernel_rules.txt, in keeping with the well-known
stable_kernel_rules.txt?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
