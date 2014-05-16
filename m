From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4: Fix VF MAC address change under RoCE
 usage
Date: Fri, 16 May 2014 15:14:05 -0400 (EDT)
Message-ID: <20140516.151405.1164437216121964890.davem@davemloft.net>
References: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
	<20140515.233958.2173839819606514748.davem@davemloft.net>
	<CAJZOPZJqqsheFBqcqM8mKYb8o9Ac2vUSRW6bkN6iZQinQwbssA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	matanb@mellanox.com, roland@kernel.org
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932AbaEPTOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 15:14:07 -0400
In-Reply-To: <CAJZOPZJqqsheFBqcqM8mKYb8o9Ac2vUSRW6bkN6iZQinQwbssA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Fri, 16 May 2014 07:58:27 +0300

> On Fri, May 16, 2014 at 6:39 AM, David Miller <davem@davemloft.net> wrote:
>> Do you guys want this to go via my 'net' tree or via Roland's
>> 'infiniband' tree?
> 
> net, since the relevant feature went into 3.15-rc1 through net-next

Done, thanks.
