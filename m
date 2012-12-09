From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 09 Dec 2012 16:21:26 -0500 (EST)
Message-ID: <20121209.162126.139597191905416818.davem@davemloft.net>
References: <20121209.004656.468043362420071590.davem@davemloft.net>
	<CADVnQy=PJezr79ib=JFh9drEYVa35PbgyAahP+TDKKuD3HC81Q@mail.gmail.com>
	<CADVnQyk0Hx-LVmo+fkMzHy9cC7MQx0ACALRXVinLhto-kpv32g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934524Ab2LIVVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 16:21:30 -0500
In-Reply-To: <CADVnQyk0Hx-LVmo+fkMzHy9cC7MQx0ACALRXVinLhto-kpv32g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 9 Dec 2012 16:15:07 -0500

> On Sun, Dec 9, 2012 at 1:01 AM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Sun, Dec 9, 2012 at 12:46 AM, David Miller <davem@davemloft.net> wrote:
>>>
>>> Thanks a lot for working on a complete fix for these problems, I'll
>>> review these patches soon.
>>
>> Thanks, David! I appreciate it.
> 
> I noticed another related validation issue, and submitted a separate
> patch for that one, based on those previous three:
> 
>    http://patchwork.ozlabs.org/patch/204786/
> 
> Please let me know if you'd like be to regenerate them all as a single
> 4-patch series instead.

What you did is fine, thanks Neal.
