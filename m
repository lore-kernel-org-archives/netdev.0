From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 17:39:20 +0900
Message-ID: <4A41E638.8060105@miraclelinux.com>
References: <C27F8246C663564A84BB7AB343977242178EE78081@IRVEXCHCCR01.corp.ad.broadcom.com>	<4A41BD86.9050208@miraclelinux.com>	<20090624.000852.186373553.davem@davemloft.net> <20090624.001625.113516382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:26881 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbZFXIjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:39:19 -0400
In-Reply-To: <20090624.001625.113516382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I'm sorry to trouble you.
I will check it in the next time.

Best Regards,
Naohiro Ooiwa

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 24 Jun 2009 00:08:52 -0700 (PDT)
> 
>> From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
>> Date: Wed, 24 Jun 2009 14:45:42 +0900
>>
>>> Hi Michael
>>>
>>> Thank you for your reply.
>>>
>>> I tested this patch now.
>>> The result was good for me.
>> I've applied your patch, thank you.
> 
> Actually, you change gives the following build warning.
> 
> drivers/net/bnx2.c:7403: warning: initialization from incompatible pointer type
> 
> I'll fix it up, but please take care of such trivial issues before
> you submit your patch.
> 
> Thanks.


