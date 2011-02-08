From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipsec: allow to align IPv4 AH on 32 bits
Date: Tue, 08 Feb 2011 14:00:56 -0800 (PST)
Message-ID: <20110208.140056.260090698.davem@davemloft.net>
References: <4D42839C.3050401@6wind.com>
	<20110128.114610.193716130.davem@davemloft.net>
	<4D49864E.8020002@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082Ab1BHWAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:00:21 -0500
In-Reply-To: <4D49864E.8020002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 02 Feb 2011 17:29:02 +0100

> On 28/01/2011 20:46, David Miller wrote:
>> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
>> Date: Fri, 28 Jan 2011 09:51:40 +0100
>>
>>> On 28/01/2011 05:51, Herbert Xu wrote:
>>>> So perhaps an SA configuration flag is needed?
>>> I agree. If David is ok, I will update the patch.
>>
>> Sounds good to me.
> 
> Here is the new patch.

I've applied this to net-next-2.6, thanks.
