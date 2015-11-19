From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/14] net: extend busy polling support
Date: Thu, 19 Nov 2015 12:05:57 -0500 (EST)
Message-ID: <20151119.120557.204429470333426888.davem@davemloft.net>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
	<20151118.161826.1686345343654337694.davem@davemloft.net>
	<1447952032.22599.231.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	eliezer.tamir@linux.intel.com, eli@mellanox.com,
	eugenia@mellanox.com, ariel.elior@qlogic.com, willemb@google.com,
	rida@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbbKSRF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:05:59 -0500
In-Reply-To: <1447952032.22599.231.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2015 08:53:52 -0800

> On Wed, 2015-11-18 at 16:18 -0500, David Miller wrote:
>> ers (by disabling busy polling on them)
>> > or revert this last patch.
>> 
>> I like this series a lot, and hope we can fix any fallout quickly and
>> painlessly.
>> 
>> Applied to net-next.
> 
> Thanks David. Could you push your tree so that we can start the testing
> phase on more drivers ?

Done :)
