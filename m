From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix cdc-phonet build
Date: Fri, 29 Jul 2011 17:45:43 -0700 (PDT)
Message-ID: <20110729.174543.80700032170015148.davem@davemloft.net>
References: <201107262320.22338.chris2553@googlemail.com>
	<20110727.224117.389682636642939049.davem@davemloft.net>
	<201107292149.58759.chris2553@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chris2553@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab1G3Ap5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 20:45:57 -0400
In-Reply-To: <201107292149.58759.chris2553@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Clayton <chris2553@googlemail.com>
Date: Fri, 29 Jul 2011 21:49:58 +0100

> On Thursday 28 July 2011 06:41:17 David Miller wrote:
>> From: Chris Clayton <chris2553@googlemail.com>
>> Date: Tue, 26 Jul 2011 23:20:22 +0100
>>
>> > cdc-phonet does not presently build on linux-3.0 because there is no
>> > entry for it in drivers/net/Makefile. This patch adds that entry.
>> >
>> > Signed-off-by: Chris Clayton <chris2553@googlemail.com>
>>
>> Applied, thanks.
> 
> Actually, I've just checked and the same problem exists in 2.6.39.3, so once the patch is Linus' 
> tree, I guess it should go in stable too. Do you have that in hand, David or should I send to 
> stable once the patch is applied to mainline?

I know it's also broken there, and I'll take care of submitting it to
-stable.
