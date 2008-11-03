From: Jianjun Kong <jianjun@zeuux.org>
Subject: Re: [PATCH] nets: clean up net/ipv4/*
Date: Mon, 3 Nov 2008 16:19:05 +0800
Message-ID: <20081103081905.GA14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:60099 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754973AbYKCIS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:18:57 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 02, 2008 at 07:00:51PM +0100, Eric Dumazet wrote:
> Jianjun Kong a ?crit :
>> clean up net/ipv4/* about code style.
>>
>> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
>>
>> ---
>>  net/ipv4/ah4.c                  |    4 +-
>>  net/ipv4/arp.c                  |   18 +++---

<sign>
> Hello Jianun
>
> For this kind of cleanup, you should probably base it on net-next-2.6
>
> And on this tree, net/ipv4/udp.c already was changed, your patch wont apply.
>
> Also, its hard to review such large patch, that easily can contain an error.

Thans for your guide ;)

I have creat six small patch of this, and it base on net-next-2.6.

Patches following this letter.
