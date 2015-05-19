From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Tue, 19 May 2015 12:25:12 +0300
Message-ID: <CAPcc5Pg5AqFtynB_twW3ycyH+GXtMr8XLUTWGAoHhNFqXrE6+Q@mail.gmail.com>
References: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
	<20150517.130516.2208900458780152420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36649 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbbESJZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 05:25:14 -0400
Received: by lagv1 with SMTP id v1so13884382lag.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 02:25:12 -0700 (PDT)
In-Reply-To: <20150517.130516.2208900458780152420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 17, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Sun, 17 May 2015 16:02:11 +0300
>
>> We didn't get a response yet regarding your comment about the irq
>> renaming [3].
>
> Well then, please hold off on resubmissions of this series until you
> do get a response and that issue is firmly resolved.
Hi,

I don't mean to push you, I only want to understand what is expected
from me and what are the next steps:
How will the issue be resolved? Do you plan to answer my question [1]
from last week, and just too busy right now or something like that?

Will sending the patchset with the irq renaming removed, make things
easier? It means that at first the irq names in /proc/interrupts won't
have the interface name in it. We can fix it later on after resolving
the problem with the current approach of irq naming. Is this
acceptable by you?

[1] - http://www.spinics.net/lists/netdev/msg328556.html

Thanks,
Amir
