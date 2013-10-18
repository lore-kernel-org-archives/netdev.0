From: Ben Greear <greearb@candelatech.com>
Subject: Re: Any suggestions for a 40G Ethernet NIC?
Date: Thu, 17 Oct 2013 18:08:45 -0700
Message-ID: <52608A1D.4060805@candelatech.com>
References: <5260248B.3090400@candelatech.com> <526088B6.7070503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36359 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab3JRBJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 21:09:17 -0400
In-Reply-To: <526088B6.7070503@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2013 06:02 PM, Ding Tianhong wrote:
> On 2013/10/18 1:55, Ben Greear wrote:
>> I'd like to start playing around with 40G, but doesn't seem to be too
>> many such NICs available.  Does anyone have any suggestions for 40G NICs
>> that work well with Linux?
>>
>> Thanks,
>> Ben
>>
>
> I have the situation for test 40G for Linux, which consist of 4 82599 NICs,
> and I use bonding LACP mode to test the performance, when turn on the iommu for
> kernel, the performance is up to 30G, when close it, the performance is up to 38G,
> what do you think about it?

Nice performance!

But, for my purposes, I need a real 40g port to test some other 40g
equipment.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
