From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and print_ipv6
Date: Wed, 26 Sep 2007 01:18:22 -0400
Message-ID: <46F9EB9E.90509@pobox.com>
References: <1190271211.26101.91.camel@localhost> <20070925.192917.21908774.davem@davemloft.net> <1190781398.17052.18.camel@localhost> <20070925.221115.26296263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45658 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbXIZFS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 01:18:29 -0400
In-Reply-To: <20070925.221115.26296263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 25 Sep 2007 21:36:38 -0700
> 
>> On Tue, 2007-09-25 at 19:29 -0700, David Miller wrote:
>>> I'm going to hold on this for now, there is no universal
>>> agreement that this is something we want to do and I'd
>>> like to take care of getting the more certain stuff into
>>> net-2.6.24 before "iffy" bits like this one.
>> Here's an argument for inclusion:
>>
>> defconfig without patches:
> 
> Sure, but this ignores certain things that text/data/bss
> size don't show you.

size(1) output also ignores the merge noise this creates, and IMO we've 
got a lot of that already...

	Jeff



