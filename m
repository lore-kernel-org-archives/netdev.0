From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net 0/2] Clean up netfilter cache on xmit-to-self.
Date: Thu, 05 Aug 2010 11:43:37 -0700
Message-ID: <4C5B0659.7020105@candelatech.com>
References: <1279828488-17800-1-git-send-email-greearb@candelatech.com>	<20100725.215912.39197141.davem@davemloft.net> <20100725.220104.59695038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46321 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab0HESni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 14:43:38 -0400
In-Reply-To: <20100725.220104.59695038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2010 10:01 PM, David Miller wrote:
> From: David Miller<davem@davemloft.net>
> Date: Sun, 25 Jul 2010 21:59:12 -0700 (PDT)
>
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Thu, 22 Jul 2010 12:54:46 -0700
>>
>>> These patches are against 2.6.34.1.  The first one may be
>>> worth submitting to stable.  The second one is less critical
>>> and should probably just go in the development tree.
>>
>> I'll apply the first one to net-2.6 and queue up for -stable

As far as I can tell, this didn't make it into -stable yet?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

