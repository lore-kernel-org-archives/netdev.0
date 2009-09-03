From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 16:22:05 -0700 (PDT)
Message-ID: <20090903.162205.257633986.davem@davemloft.net>
References: <4A9E2CC7.1010103@gmail.com>
	<alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1>
	<Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, eric.dumazet@gmail.com, jarkao2@gmail.com,
	kaber@trash.net, netdev@vger.kernel.org
To: hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34089
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756035AbZICXVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 19:21:51 -0400
In-Reply-To: <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@diku.dk>
Date: Thu, 3 Sep 2009 16:19:44 +0200 (CEST)

> 
> On Wed, 2 Sep 2009, Christoph Lameter wrote:
>> On Wed, 2 Sep 2009, Eric Dumazet wrote:
>>
>>> Same name "eth0" is displayed, that might confuse parsers...
>>>
>>> What naming convention should we choose for multiqueue devices ?
>>
>> eth0/tx<number> ?
> 
> Remember that we already have a naming convention in /proc/interrupts
> 
>  eth0-tx-<number>
> 
> Lets not introduce too many new once ;-)

Yes, please :-)
