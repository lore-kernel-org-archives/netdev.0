From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] sh_eth: fix bugs in sh_eth_ring_init()
Date: Mon, 02 Nov 2015 22:32:52 -0500 (EST)
Message-ID: <20151102.223252.1187774093228458041.davem@davemloft.net>
References: <3291270.dPgp9opalf@wasted.cogentembedded.com>
	<20151102.155639.1614788692883883662.davem@davemloft.net>
	<5637E44D.1070006@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbbKCDc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 22:32:56 -0500
In-Reply-To: <5637E44D.1070006@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 3 Nov 2015 01:31:41 +0300

> On 11/02/2015 11:56 PM, David Miller wrote:
> 
>>>     Here's a set of 2 patches against DaveM's 'net.git' repo which fix
>>>     couple of
>>> bugs in the sh_eth_ring_init() function.
>>
>> Series applied.
> 
>    As these fixed the error path, I don't expect you to push them to
>    -stable, but your call.

It's actually more your call, not mine.
