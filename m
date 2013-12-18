From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 01/15] net: bnx2 calls skb_set_hash
Date: Wed, 18 Dec 2013 12:07:54 -0800
Message-ID: <CA+mtBx_Jcwj48nwM2i4a_EZr70c+Xgdxm68d7gSqM=P4QrnD1g@mail.gmail.com>
References: <alpine.DEB.2.02.1312172316170.24380@tomh.mtv.corp.google.com>
	<20131218.150139.1988567237207931172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:43348 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab3LRUHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 15:07:55 -0500
Received: by mail-ie0-f170.google.com with SMTP id qd12so202424ieb.29
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 12:07:54 -0800 (PST)
In-Reply-To: <20131218.150139.1988567237207931172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks! I'll clean up bnx2x also per David's comment.

On Wed, Dec 18, 2013 at 12:01 PM, David Miller <davem@davemloft.net> wrote:
>
> All applied except for #6, #7, #8, #9 which Jeff Kirsher said would
> take via his tree.
>
> Thanks.
