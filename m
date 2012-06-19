From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:16:13 -0700 (PDT)
Message-ID: <20120618.211613.921381844240194486.davem@davemloft.net>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	<a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
	<CABa6K_E+EzeJQF_m4aoq1WAYUwWQxd8_=k7HT0XZ6P5EpBR+4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413Ab2FSEQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:16:14 -0400
In-Reply-To: <CABa6K_E+EzeJQF_m4aoq1WAYUwWQxd8_=k7HT0XZ6P5EpBR+4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 19 Jun 2012 12:13:48 +0800

> On Tue, Jun 19, 2012 at 12:03 PM, Stephen Hemminger
> <stephen.hemminger@vyatta.com> wrote:
>>
>>>
>>> You know you want it.
>>>
>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> David, I understand it, Eric understands it, and maybe one or
>> two others. But on the principal of what is "good for the goose
>> is good for the gander", you really need to provide a reasonable
>> change log entry. Just because you are the network maintainer
>> doesn't mean you get to skip all the documented rules about submitting
>> patches.
> 
> Agree. Thanks.

That's the last time I try to be even slightly humerous on this
list.

Thanks for killing the fun Stephen.
