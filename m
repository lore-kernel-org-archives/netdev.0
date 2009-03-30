From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Mon, 30 Mar 2009 21:59:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
References: <20090330085302.19172.22808.stgit@localhost.localdomain>
 <20090330090306.19172.94170.stgit@localhost.localdomain> <49D0FA6E.4090402@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:52477 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760323AbZC3UAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 16:00:01 -0400
In-Reply-To: <49D0FA6E.4090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Mar 2009, Jarek Poplawski wrote:

> Jesper Dangaard Brouer wrote, On 03/30/2009 11:03 AM:
>
>> Trival spelling fixes in RCU/rculist_nulls.txt.
>>
>>  the lookup met the end of chain. If final 'nulls' value
>>  is not the slot number, then we must restart the lookup at
>> -the begining. If the object was moved to same chain,
>> +the beginning. If the object was moved to same chain,
>
>
> "by way":)
> +the beginning. If the object was moved to the same chain,

*LOL* this was suppose to be a simple trivial insignificant fix, but you 
are right there is _also_ missing a "the" in the sentence ;-).

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
