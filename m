From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix mglist corruption that leads to memory corruption
Date: Sat, 12 Feb 2011 01:06:26 -0800 (PST)
Message-ID: <20110212.010626.200383948.davem@davemloft.net>
References: <20110211225559.GA5922@gondor.apana.org.au>
	<20110211.215804.15260765.davem@davemloft.net>
	<20110212060538.GA911@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ihands@redhat.com, jbacik@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751699Ab1BLJFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 04:05:51 -0500
In-Reply-To: <20110212060538.GA911@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 12 Feb 2011 17:05:38 +1100

> On Fri, Feb 11, 2011 at 09:58:04PM -0800, David Miller wrote:
>>
>> Well if it's a bool, please use "true" and "false" instead of "1" and
>> "0" :-)
> 
> Serves me right for trying to be green :)
> 
> bridge: Replace mp->mglist hlist with a bool

:-)  Applied.
