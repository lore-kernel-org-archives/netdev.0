From: David Miller <davem@davemloft.net>
Subject: Re: [Alternative PATCH net-next] sctp: fix test for end of loop
Date: Thu, 09 Sep 2010 15:00:51 -0700 (PDT)
Message-ID: <20100909.150051.115922917.davem@davemloft.net>
References: <20100908.133747.232732909.davem@davemloft.net>
	<1283979861.2479.21.camel@Joe-Laptop>
	<4C88E7CB.7060804@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, error27@gmail.com, sri@us.ibm.com,
	yjwei@cn.fujitsu.com, cascardo@holoscopio.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52192
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753208Ab0IIWAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 18:00:34 -0400
In-Reply-To: <4C88E7CB.7060804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 09 Sep 2010 09:57:31 -0400

> On 09/08/2010 05:04 PM, Joe Perches wrote:
>> Perhaps something like this is clearer?
>> 
>> Add a list_has_sctp_addr function to simplify loop
>> 
>> Based on a patches by Dan Carpenter and David Miller
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Thanks Joe
> 
> I like this.  Nice and clean. :)
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6 since this is reasonably important bug fix.

Thanks guys!
