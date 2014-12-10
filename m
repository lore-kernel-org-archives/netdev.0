From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Wed, 10 Dec 2014 16:15:32 +0800
Message-ID: <54880124.8040509@cn.fujitsu.com>
References: <5487DBD9.1010908@cn.fujitsu.com> <1418194583.1047.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:17693 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750716AbaLJIb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 03:31:26 -0500
In-Reply-To: <1418194583.1047.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,
On 12/10/2014 02:56 PM, Joe Perches wrote:

> On Wed, 2014-12-10 at 13:36 +0800, Gu Zheng wrote:
>> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
>> cmsghdr from msghdr, just cleanup. 
> 
> This looks nicer.
> Ideally this would have used: [PATCH V3] as the subject

Thanks for your review.
The previous v2 thread was marked as mistake, so this is the really active
v2 version.

Regards,
Gu

> 
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
>> ---
>> v2: use the lower-case macro name as Joe suggested.
> 
> And a description of the v2->v3 change here.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
