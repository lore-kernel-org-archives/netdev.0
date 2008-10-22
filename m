From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Wed, 22 Oct 2008 18:01:48 +0200
Message-ID: <48FF4E6C.1070407@trash.net>
References: <20081017130333.GA8297@ff.dom.local>	<48F89D33.9090809@trash.net>	<20081017204543.GB2527@ami.dom.local> <20081021.164342.135191750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55970 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403AbYJVQBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 12:01:50 -0400
In-Reply-To: <20081021.164342.135191750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 17 Oct 2008 22:45:43 +0200
> 
>> BTW, I'm not sure if I'm expected to redo any patches in this thread.
>> (Probably some things like this teql_peek() could be removed with
>> ->requeue() killing.)
> 
> In any event, you should resubmit these when I open the net-next-2.6
> tree up in about a week or so.
> 
> It looks like Patrick is in agreement about these changes and they
> look mostly fine to me too, FWIW.

I think I lost the overview :) I'll review them again once the complete
batch is resent.
