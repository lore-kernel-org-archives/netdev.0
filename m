From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 0/20][IPV6/XFRM] MIPv6 CN (part B)
Date: Wed, 02 Aug 2006 17:26:12 +0900
Message-ID: <44D061A4.8050807@linux-ipv6.org>
References: <44CB2914.9010803@linux-ipv6.org>	<44CB2A2D.4090808@linux-ipv6.org>	<44CB2C40.9040900@linux-ipv6.org> <20060801.173051.35665426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:20114 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751362AbWHBI0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 04:26:15 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060801.173051.35665426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:37:04 +0900
> 
>> Here is Part B patches, following this mail.
>>
>> Part B is also available as mip6cn-20060716-review branch at:
>>
>> git://git.skbuff.net:9419/gitroot/nakam/linux-2.6-mip6cn
>>
>> This tree includes part A, then it has all patches about
>> "Advanced XFRM for CN".
> 
> These patches mainly deal with the specifics of ipv6
> mobility processing, they look mostly fine to me and
> I could not spot any obvious errors.

Thank you for reviewing.

Next time I prepare the patch for the latest tree
with fixes about comments.

Thanks,

-- 
Masahide NAKAMURA
