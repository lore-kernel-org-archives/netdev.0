From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Wed, 17 Jul 2013 11:08:29 -0400
Message-ID: <51E6B36D.8010904@windriver.com>
References: <20130716025954.GC26761@windriver.com> <20130716.130514.559781233978406598.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <dvhart@linux.intel.com>, <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51372 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162Ab3GQPI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 11:08:27 -0400
In-Reply-To: <20130716.130514.559781233978406598.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-16 04:05 PM, David Miller wrote:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 15 Jul 2013 22:59:54 -0400
> 
>> I was wondering if you think there is value in having a netdev-faq type
>> document available -- perhaps as a vger mailout to new subscribers or
>> similar?  For example, I have lost count of the number of times that you
>> have had to tell people that net-next is closed during the merge window.
>> But you would probably be right in telling me that those same people don't
>> read documentation.  Well, that aside, I suppose answering my question
>> is easier when there is a proposed starting point for content.
>>
>> To that end, I've tried to collect a starting point based on repeated
>> questions/corrections that I've seen over the years.  I've added Greg to
>> the Cc: in order to ensure I've captured the netdev-stable interaction
>> correctly, and I've thrown Darren under the bus as a random content
>> reviewer, since he has expressed an interest in documentation recently.
>>
>> Below is a possible starting point for content.  Many answers I have
>> written are from memory, long after losing links to netdev threads that
>> served as evidence for the answers, so apologies in advance if I have
>> failed to recall correctly the specific details in which you would like
>> to see things done.
> 
> Thanks a lot for writing this, it is useful.
> 
> I think it's easier if this lives somewhere under
> Documentation/networking in the kernel tree, then we can just point
> people at it.
> 
> What do you think?

Sounds fine to me, I'll make some of the corrections Darren pointed out
and send it along as a patch.
