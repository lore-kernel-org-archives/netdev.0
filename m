From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet
 driver
Date: Tue, 19 May 2015 12:41:28 -0400 (EDT)
Message-ID: <20150519.124128.353071028525864155.davem@davemloft.net>
References: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
	<20150517.130516.2208900458780152420.davem@davemloft.net>
	<CAPcc5Pg5AqFtynB_twW3ycyH+GXtMr8XLUTWGAoHhNFqXrE6+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	achiad@mellanox.com, saeedm@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbbESQla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 12:41:30 -0400
In-Reply-To: <CAPcc5Pg5AqFtynB_twW3ycyH+GXtMr8XLUTWGAoHhNFqXrE6+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 19 May 2015 12:25:12 +0300

> On Sun, May 17, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Amir Vadai <amirv@mellanox.com>
>> Date: Sun, 17 May 2015 16:02:11 +0300
>>
>>> We didn't get a response yet regarding your comment about the irq
>>> renaming [3].
>>
>> Well then, please hold off on resubmissions of this series until you
>> do get a response and that issue is firmly resolved.
> Hi,
> 
> I don't mean to push you, I only want to understand what is expected
> from me and what are the next steps:
> How will the issue be resolved? Do you plan to answer my question [1]
> from last week, and just too busy right now or something like that?

I have not seen any response to me explaining why it's ok to change
the IRQ name strings in the context where this will occur.

Once you explain that, we can make forward progress, but only at that
point.
