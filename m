From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] net: introduce helper macra CMSG_FOREACH_HDR
Date: Tue, 09 Dec 2014 15:23:25 -0500 (EST)
Message-ID: <20141209.152325.555830295797189797.davem@davemloft.net>
References: <54815B40.1050909@cn.fujitsu.com>
	<1417766552.2721.45.camel@perches.com>
	<54816CD3.90107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: guz.fnst@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54816CD3.90107@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Date: Fri, 5 Dec 2014 16:29:07 +0800

> Hi Joe,
> Thanks for your comment.
> On 12/05/2014 04:02 PM, Joe Perches wrote:
> 
>> On Fri, 2014-12-05 at 15:14 +0800, Gu Zheng wrote:
>>> Introduce helper macra
>> 
>> macro
> 
> Ah~, it's a typo.
> 
>> 
>>> CMSG_FOREACH_HDR as a wrapper of the enumerating
>>> cmsghdr from msghdr, just cleanup. 
>> 
>> maybe better to use lower case "for_each_cmsg_hdr"
>> or some such.
> 
> But this will make it out of the ordinary, as the existed ones
> are all upper.
> 
> David, what's your opinion?

I think lowercase looks much better.
