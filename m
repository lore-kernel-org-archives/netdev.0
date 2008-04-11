From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 20:27:14 -0400
Message-ID: <47FEB062.3020003@rtr.ca>
References: <9a8748490804101509l5d043ff8w565dc44dfeaf0072@mail.gmail.com>	<20080410.154651.101700010.davem@davemloft.net>	<47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:1030 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbYDKA1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 20:27:17 -0400
In-Reply-To: <20080410.172453.44434205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Mark Lord <lkml@rtr.ca>
> Date: Thu, 10 Apr 2008 20:16:11 -0400
> 
>> Duh.. more like, "If I take 5-8 hours to attempt a bisect (which may not
>> even work), then that's 5-8 hours I do not get paid for."
> 
> And if I invest my spare time on your bug
> how does this statement apply to me?
..

It's not "my bug".  I'm just the first person to notice,
take time to report it, and even hand it to you on a platter (bisect).

It's *your* bug -- you signed off on the commit.

Cheers
