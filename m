From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bridge: cleanup: remove unused assignment
Date: Sun, 21 Mar 2010 21:30:49 -0700 (PDT)
Message-ID: <20100321.213049.26945651.davem@davemloft.net>
References: <20100320112049.GU5331@bicker>
	<20100320115747.GA1849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, paulmck@linux.vnet.ibm.com,
	michael-dev@fami-braun.de, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0CVEa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 00:30:27 -0400
In-Reply-To: <20100320115747.GA1849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Mar 2010 19:57:47 +0800

> On Sat, Mar 20, 2010 at 02:20:49PM +0300, Dan Carpenter wrote:
>> We never actually use iph again so this assignment can be removed.
>> 
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
