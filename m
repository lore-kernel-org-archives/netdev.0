From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT
 sample
Date: Tue, 10 Apr 2012 17:16:37 -0400 (EDT)
Message-ID: <20120410.171637.622088330832657275.davem@davemloft.net>
References: <CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
	<20120410.170749.354288312321198124.davem@davemloft.net>
	<1334092294.5300.614.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, ncardwell@google.com, netdev@vger.kernel.org,
	nanditad@google.com, ycheng@google.com, edumazet@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732Ab2DJVQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 17:16:41 -0400
In-Reply-To: <1334092294.5300.614.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Apr 2012 23:11:34 +0200

> On Tue, 2012-04-10 at 17:07 -0400, David Miller wrote:
>> From: Dave Taht <dave.taht@gmail.com>
>> Date: Tue, 10 Apr 2012 13:46:38 -0700
>> 
>> > awesome, is this needed in stable?
>> 
>> I have it queued up there already.
>> 
>> But you didn't need to write your email at all, you could
>> have checked this yourself:
>> 
>> http://patchwork.ozlabs.org/user/bundle/2566/?state=*
> 
> Not sure this URL works (it doesnt for me)

Sorry, that's my private URL and only works if you're logged
in as me :-)  This one is better:

http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
