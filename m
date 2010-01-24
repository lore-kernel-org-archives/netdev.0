From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns xfrm: fix "ip xfrm state|policy count" misreport
Date: Sat, 23 Jan 2010 23:30:56 -0800 (PST)
Message-ID: <20100123.233056.193698373.davem@davemloft.net>
References: <20100123233709.GA4157@x200>
	<20100124001252.GA11585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752282Ab0AXHap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 02:30:45 -0500
In-Reply-To: <20100124001252.GA11585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2010 13:12:52 +1300

> On Sun, Jan 24, 2010 at 01:37:10AM +0200, Alexey Dobriyan wrote:
>> "ip xfrm state|policy count" report SA/SP count from init_net,
>> not from netns of caller process.
>> 
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Looks good to me.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
