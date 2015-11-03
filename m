From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 0/2] sh_eth: fix bugs in sh_eth_ring_init()
Date: Tue, 3 Nov 2015 15:02:38 +0300
Message-ID: <5638A25E.5070406@cogentembedded.com>
References: <3291270.dPgp9opalf@wasted.cogentembedded.com>
 <20151102.155639.1614788692883883662.davem@davemloft.net>
 <5637E44D.1070006@cogentembedded.com>
 <20151102.223252.1187774093228458041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33910 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbKCMCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 07:02:42 -0500
Received: by lfgh9 with SMTP id h9so14917342lfg.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 04:02:41 -0800 (PST)
In-Reply-To: <20151102.223252.1187774093228458041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2015 6:32 AM, David Miller wrote:

>>>>      Here's a set of 2 patches against DaveM's 'net.git' repo which fix
>>>>      couple of
>>>> bugs in the sh_eth_ring_init() function.
>>>
>>> Series applied.
>>
>>     As these fixed the error path, I don't expect you to push them to
>>     -stable, but your call.
>
> It's actually more your call, not mine.

    Well, I don't think the error path fixes are worth putting into -stable, I 
just don't know what's your usual policy on these...

MBR, Sergei
