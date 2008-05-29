From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Thu, 29 May 2008 09:27:21 -0400
Message-ID: <483EAF39.1040302@pobox.com>
References: <48365CBF.4080502@cn.fujitsu.com> <20080529.033442.175635712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43261 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbYE2N1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 09:27:25 -0400
In-Reply-To: <20080529.033442.175635712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 23 May 2008 13:57:19 +0800
> 
>> 1. dma should be freed when dma2 request fail.
>> 2. dma2 should be freed too when device close.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Jeff, did you get this or would you like me to pick
> it up directly?

I never pick up IRDA stuff.

	Jeff



