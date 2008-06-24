From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] NET: Proper handling of IPv6 header in tun driver when
 TUN_NO_PI is set
Date: Mon, 23 Jun 2008 22:09:46 -0700
Message-ID: <4860819A.4030809@qualcomm.com>
References: <48499C32.6070703@qualcomm.com>	<20080617.163205.160864233.davem@davemloft.net>	<48586F4B.4060404@nav6.org> <20080617.210803.190930256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wcang@nav6.org, steve.zabele@baesystems.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:5915 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbYFXFJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 01:09:48 -0400
In-Reply-To: <20080617.210803.190930256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ang Way Chuang <wcang@nav6.org>
> Date: Wed, 18 Jun 2008 10:13:31 +0800
> 
>> David Miller wrote:
>>> From: Max Krasnyanskiy <maxk@qualcomm.com>
>>> Date: Fri, 06 Jun 2008 13:21:06 -0700
>>>
>>>> Acked-by: Max Krasnyansky <maxk@qualcomm.com>
>>>>
>>>> Dave, can you please add this patch to your tree.
>>> I can't, the patch is severely whitespace damaged.
>>>
>> Resend. Hopefully Thunderbird won't screw this time.
> 
> Same problem, tabs were transformed into spaces, and
> lines composed of only whitespace were transformed into
> empty lines.
> 
> This is frustrating enough, I'm just going to fix this up
> by hand for you, but please get your shit straight for next
> time because I won't do this twice.

Dave, thanks a lot for fixing this up. I looked at the patch and logic wise it
looked perfectly fine. I did not notice the problem with the spaces. Sorry.

Max
