From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: remove unused cpu_off
Date: Tue, 17 Apr 2012 23:21:06 -0400 (EDT)
Message-ID: <20120417.232106.186221097843548596.davem@davemloft.net>
References: <1334717479.2472.73.camel@edumazet-glaptop>
	<20120417.225733.605856895750092515.davem@davemloft.net>
	<1334717992.2472.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2DRDVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 23:21:08 -0400
In-Reply-To: <1334717992.2472.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Apr 2012 04:59:52 +0200

> On Tue, 2012-04-17 at 22:57 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 18 Apr 2012 04:51:19 +0200
>> 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Applied, but I added "in sparc JIT" to the subject line.
>> 
>> Thanks.
> 
> No problem, I just copy/pasted your own subjects for this file 

They all had sparc in them :-)

David S. Miller (3):
      net: filter: Just In Time compiler for sparc
      net: filter: Fix some minor issues in sparc JIT.
      net: filter: Fix some more small issues in sparc JIT.
