From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_nat: use stack variable
Date: Wed, 30 Jun 2010 12:12:52 -0700 (PDT)
Message-ID: <20100630.121252.228948995.davem@davemloft.net>
References: <1277888829-30230-1-git-send-email-xiaosuo@gmail.com>
	<1277893521.3509.17.camel@bigi>
	<20100630103005.GA24688@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754846Ab0F3TMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 15:12:39 -0400
In-Reply-To: <20100630103005.GA24688@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 30 Jun 2010 18:30:05 +0800

> On Wed, Jun 30, 2010 at 06:25:21AM -0400, jamal wrote:
>> On Wed, 2010-06-30 at 17:07 +0800, Changli Gao wrote:
>> > act_nat: use stack variable
>> > 
>> > structure tc_nat isn't too big for stack, so we can put it in stack.
>> > 
>> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> 
>> Doesnt look unreasonable - will let Herbert make the call..
> 
> Looks good to me too.

Applied.
