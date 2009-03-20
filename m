From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]spider_net:remove '&' in the init of function pointers
Date: Fri, 20 Mar 2009 16:32:35 +0800
Message-ID: <49C354A3.7020807@cn.fujitsu.com>
References: <49C3515D.7090703@cn.fujitsu.com> <20090320.012152.95177338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, kou.ishizaki@toshiba.co.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60076 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbZCTIdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:33:23 -0400
In-Reply-To: <20090320.012152.95177338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Fri, 20 Mar 2009 16:18:37 +0800
> 
>> Do not need '&' in the init of function pointers.
>>
>> Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
> 
> It's harmless, just leave it alone.  This is just going to be commit
> noise.
> 
> More useful would be to convert this driver over to net_device_ops.

I'll do that.

> 
> I'm not applying this.
> 
> 


-- 
Regards
Yang Hongyang
