From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/04: netfilter fixes
Date: Thu, 28 May 2009 18:34:21 +0200
Message-ID: <4A1EBD0D.7090303@trash.net>
References: <20090527143521.4649.73610.sendpatchset@x2.localnet> <20090527.155235.79198381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47551 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763423AbZE1QeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 12:34:24 -0400
In-Reply-To: <20090527.155235.79198381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 27 May 2009 16:35:24 +0200 (MEST)
> 
>> following are four netfilter fixes for 2.6.30, containing:
>>
>> - a patch from Jozsef to fix accepting invalid RST packets in TCP conntrack
>> - a patch from Pablo to properly propagate DCCP conntrack state changes
>> - a patch from Jesper to fix an invalid return value in a xt_hashlimit
>>   seq_file function
>> - another patch from Pablo to fix undersized skb allocation in nfnetlink_log
>>
>> Please apply or pull from:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git
> 
> Pulled, thanks Patrick.
> 
> In the future, can you please explicitly specify the branch name, even
> if it is just 'master', in your GIT URLs for me to pull from?
> 
> GIT requires that it always be specified, therefore if you put it
> there at the end of the URL I can just cut and paste it into my
> command line.

Sure, will do :)

