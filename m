From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] iproute2: allow to specify truncation bits on auth algo
Date: Mon, 28 Feb 2011 14:46:12 +0100
Message-ID: <4D6BA724.2020504@6wind.com>
References: <20110128045108.GA8351@gondor.apana.org.au>	<4D42839C.3050401@6wind.com> <20110128.114610.193716130.davem@davemloft.net> <4D498693.6020909@6wind.com> <4D49879B.4060108@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, christophe.gouault@6wind.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56545 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab1B1NqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 08:46:17 -0500
Received: by bwz15 with SMTP id 15so3647969bwz.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 05:46:16 -0800 (PST)
In-Reply-To: <4D49879B.4060108@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

what is the status of this patch? It has been set to 'Superseded' in the 
patchwork tool (http://patchwork.ozlabs.org/patch/81486/).
Kernel headers have been updated in iproute2, should I resend the patch?


Regards,
Nicolas

On 02/02/2011 17:34, Nicolas Dichtel wrote:
> On 02/02/2011 17:30, Nicolas Dichtel wrote:
>> On 28/01/2011 20:46, David Miller wrote:
>>> From: Nicolas Dichtel<nicolas.dichtel@6wind.com>
>>> Date: Fri, 28 Jan 2011 09:51:40 +0100
>>>
>>>> On 28/01/2011 05:51, Herbert Xu wrote:
>>>>> So perhaps an SA configuration flag is needed?
>>>> I agree. If David is ok, I will update the patch.
>>>
>>> Sounds good to me.
>> And the patch for iproute2.
> Sorry, two patches were mixed :(
>
> Here is the right one.
>
>
> Regards,
> Nicolas
