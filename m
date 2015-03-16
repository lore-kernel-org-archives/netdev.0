From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 16:25:44 -0400 (EDT)
Message-ID: <20150316.162544.1877335664503541576.davem@davemloft.net>
References: <20150316043359.GA29124@gondor.apana.org.au>
	<20150316.004017.1903871383239941874.davem@davemloft.net>
	<20150316112628.GA1373@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbbCPUZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:25:46 -0400
In-Reply-To: <20150316112628.GA1373@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 Mar 2015 22:26:28 +1100

> On Mon, Mar 16, 2015 at 12:40:17AM -0400, David Miller wrote:
>>
>> Patrick McHardy had mentioned to me his consternation about this issue
>> offhand the other week, and I've just failed to get around to bringing
>> it up :-)
> 
> How about something like this? Compile tested only but at least
> it does inline correctly.

I like it.
