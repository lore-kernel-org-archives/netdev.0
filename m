From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net 0/2] Clean up netfilter cache on xmit-to-self.
Date: Thu, 05 Aug 2010 12:29:38 -0700
Message-ID: <4C5B1122.9000206@candelatech.com>
References: <20100725.215912.39197141.davem@davemloft.net>	<20100725.220104.59695038.davem@davemloft.net>	<4C5B0659.7020105@candelatech.com> <20100805.115850.58405719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53182 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab0HET3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 15:29:40 -0400
In-Reply-To: <20100805.115850.58405719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2010 11:58 AM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Thu, 05 Aug 2010 11:43:37 -0700
>
>> On 07/25/2010 10:01 PM, David Miller wrote:
>>> From: David Miller<davem@davemloft.net>
>>> Date: Sun, 25 Jul 2010 21:59:12 -0700 (PDT)
>>>
>>>> From: Ben Greear<greearb@candelatech.com>
>>>> Date: Thu, 22 Jul 2010 12:54:46 -0700
>>>>
>>>>> These patches are against 2.6.34.1.  The first one may be
>>>>> worth submitting to stable.  The second one is less critical
>>>>> and should probably just go in the development tree.
>>>>
>>>> I'll apply the first one to net-2.6 and queue up for -stable
>>
>> As far as I can tell, this didn't make it into -stable yet?
>
> It's sitting in my queue, I will send it out once 2.6.35 has been out
> for about 1 week more just to double make sure there aren't any
> unwanted side effects.
>
> I never submit changes to -stable immediately unless the change is
> painfully obvious and has no possible unwanted side effects.  I always
> wait a week or even more sometimes.

Ok, no problem.  I just wanted to make sure it hadn't been lost.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

