From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Tue, 16 Jul 2013 13:05:14 -0700 (PDT)
Message-ID: <20130716.130514.559781233978406598.davem@davemloft.net>
References: <20130716025954.GC26761@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvhart@linux.intel.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196Ab3GPUFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:05:14 -0400
In-Reply-To: <20130716025954.GC26761@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 15 Jul 2013 22:59:54 -0400

> I was wondering if you think there is value in having a netdev-faq type
> document available -- perhaps as a vger mailout to new subscribers or
> similar?  For example, I have lost count of the number of times that you
> have had to tell people that net-next is closed during the merge window.
> But you would probably be right in telling me that those same people don't
> read documentation.  Well, that aside, I suppose answering my question
> is easier when there is a proposed starting point for content.
> 
> To that end, I've tried to collect a starting point based on repeated
> questions/corrections that I've seen over the years.  I've added Greg to
> the Cc: in order to ensure I've captured the netdev-stable interaction
> correctly, and I've thrown Darren under the bus as a random content
> reviewer, since he has expressed an interest in documentation recently.
> 
> Below is a possible starting point for content.  Many answers I have
> written are from memory, long after losing links to netdev threads that
> served as evidence for the answers, so apologies in advance if I have
> failed to recall correctly the specific details in which you would like
> to see things done.

Thanks a lot for writing this, it is useful.

I think it's easier if this lives somewhere under
Documentation/networking in the kernel tree, then we can just point
people at it.

What do you think?
