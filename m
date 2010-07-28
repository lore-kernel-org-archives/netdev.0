From: David Miller <davem@davemloft.net>
Subject: Re: br_forward.c - rcu dereference warning
Date: Wed, 28 Jul 2010 10:39:16 -0700 (PDT)
Message-ID: <20100728.103916.135547147.davem@davemloft.net>
References: <1280261679.3755.6.camel@jlt3.sipsolutions.net>
	<20100727134223.5bb0be30@nehalam>
	<1280302431.3684.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754575Ab0G1RjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 13:39:00 -0400
In-Reply-To: <1280302431.3684.0.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 28 Jul 2010 09:33:51 +0200

> On Tue, 2010-07-27 at 13:42 -0700, Stephen Hemminger wrote:
> 
>> > 
>> > Did you want me to test the patch?
>> 
>> Yes please, I can make sure it works, but not that it gets rid
>> of your error
> 
> Yes, it fixed it, thanks.

I fixed up the comment thinko Johannes noticed, added a tested-by tag,
and applied this to net-2.6

Thanks!
