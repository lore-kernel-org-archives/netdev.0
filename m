From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net-next PATCH 0/8] Fix Tunnel features and enable GSO partial
 for Mellanox adapters
Date: Fri, 29 Apr 2016 10:32:54 -0700
Message-ID: <CAMt9YRp5-RkM9r3PtvjH_rkghFvjT4XijOdvcrth5AEu7=4yfA@mail.gmail.com>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
	<20160429.133107.1317675802100306452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: talal@mellanox.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	galp@mellanox.com, ogerlitz@mellanox.com,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:36317 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbcD2Rcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 13:32:55 -0400
Received: by mail-vk0-f51.google.com with SMTP id s184so650878vkb.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 10:32:55 -0700 (PDT)
In-Reply-To: <20160429.133107.1317675802100306452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 10:31 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
> Date: Mon, 25 Apr 2016 11:30:54 -0700
>
>> This patch series is meant to allow us to get the best performance possible
>> for Mellanox ConnectX-3/4 adapters in terms of VXLAN tunnels.
>
> I'm going to mark this as "deferred" in patchwork, so Alex why don't you just
> respin these and repost next week when you get final feedback from the Mellanox
> folks?
>
> THanks.

Okay.  Will do.

Thanks.

- Alex
