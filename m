From: David Miller <davem@davemloft.net>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Mon, 03 Nov 2014 15:09:17 -0500 (EST)
Message-ID: <20141103.150917.1015521239616746570.davem@davemloft.net>
References: <CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
	<20141101.134142.888127846627939710.davem@davemloft.net>
	<CAHA+R7OMgOpnWyy5E55OtLS4naOcZ5EhzViE14Yffu=K=TqNcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, vlee@twopensource.com, amirv@mellanox.com,
	ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	eugenia@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbaKCUJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:09:21 -0500
In-Reply-To: <CAHA+R7OMgOpnWyy5E55OtLS4naOcZ5EhzViE14Yffu=K=TqNcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 3 Nov 2014 09:22:18 -0800

> On Sat, Nov 1, 2014 at 10:41 AM, David Miller <davem@davemloft.net> wrote:
>>
>> There is no documented way nor do I wish to state anything so strictly.
>> I want maximum flexibility for such a time consuming task.
>>
>> I tend to go back 3 or 4 releases at most, and it really depends upon
>> the difficulty of the backports and my own time constraints.
> 
> You should really offload to developers, otherwise too much work for you. :)

That's exactly what I am doing by having the -stable maintainers for older
releases deal with the backports and other pains.
