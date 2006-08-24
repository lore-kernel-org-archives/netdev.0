From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension headers
 sorting.
Date: Thu, 24 Aug 2006 16:05:39 +0900
Message-ID: <44ED4FC3.9060005@linux-ipv6.org>
References: <11563453682841-git-send-email-yoshfuji@linux-ipv6.org>	<20060823.225706.03601250.davem@davemloft.net>	<20060824.150442.44820672.yoshfuji@linux-ipv6.org> <20060823.235404.108743952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:45542 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1030374AbWHXHFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 03:05:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060823.235404.108743952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Aug 2006 15:04:42 +0900 (JST)
> 
>> In article <20060823.225706.03601250.davem@davemloft.net> (at Wed, 23 Aug 2006 22:57:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:
>>
>>> Are there any other Mobile-IPV6 patches necessary for the
>>> kernel?
>> The patches cover most of MIPv6 and CN should work.
>> However, for HA/MN, there are small number of patches
>> to send.
>>
>> We will send them, of course.
>> Nakamura-san, please describe the details.

I'll send them later, but anyway,

> 
> Ok, thank you.
> 
> In the mean time, I will work on porting my XFRM hashing changes
> for the current net-2.6.19 tree.

FYI, your work will not have any conflict with the left of MIPv6 patches
which I will describe later since they are almost out of XFRM.

Regards,

-- 
Masahide NAKAMURA
