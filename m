From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from ip6_dst_lookup()
 (is Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup)
Date: Wed, 27 Oct 2004 11:21:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417FBCF9.5070808@hp.com>
References: <417E5F37.4010501@hp.com>	<20041027.004359.62730834.yoshfuji@linux-ipv6.org>	<417E92D9.1050305@hp.com> <20041027.091039.56337914.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041027.091039.56337914.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Because we do not support RFC3542, extra 128bits is definitely correct.

2292 was deprecated by 3542 in May 2003, when do we plan on supporting it?  I am 
willing to do this update, just please tell me the way you want me to go about it.

Thanks,

-Brian
