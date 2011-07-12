From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Mon, 11 Jul 2011 19:45:56 -0700 (PDT)
Message-ID: <20110711.194556.1386145743297508794.davem@davemloft.net>
References: <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
	<20110711.193359.1440272794251078589.davem@davemloft.net>
	<1310438432.2438.26.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab1GLCqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 22:46:01 -0400
In-Reply-To: <1310438432.2438.26.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 11 Jul 2011 19:40:31 -0700

> On Mon, 2011-07-11 at 19:33 -0700, David Miller wrote:
>> You can't until I put patch #1 into my tree, which adds the
>> new interfaces used by this patch.
> 
> I applied patch #1 to my queue as well (for testing purposes) since I
> saw that patch #2 was dependent.  If it passes testing, I (or Bruce)
> will just ACK patch #2, that way you can apply both patches at the same
> time.

Ok.
