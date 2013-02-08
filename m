From: David Miller <davem@davemloft.net>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Thu, 07 Feb 2013 22:26:21 -0500 (EST)
Message-ID: <20130207.222621.219382606390584516.davem@davemloft.net>
References: <1358575996.3464.447.camel@edumazet-glaptop>
	<20130120.232122.1798689273842981732.davem@davemloft.net>
	<20130208023946.GA23197@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, w@1wt.eu
To: normalperson@yhbt.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab3BHD0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 22:26:25 -0500
In-Reply-To: <20130208023946.GA23197@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Wong <normalperson@yhbt.net>
Date: Fri, 8 Feb 2013 02:39:46 +0000

> David Miller <davem@davemloft.net> wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 18 Jan 2013 22:13:16 -0800
>> 
>> > On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:
>> > 
>> >> 
>> >> Hmm, this might be already fixed in net-next tree, could you try it ?
>> >> 
>> > 
>> > Yes, running your program on net-next seems OK.
>> > 
>> > David, we need the two following commits.
>> 
>> Tossed into 'net' and queued up for -stable, thanks.
> 
> Hi David, any update on getting these into -stable?  Thanks.

I submit stable patches once they have cooked upstream for
a week or two.
