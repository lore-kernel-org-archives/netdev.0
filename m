From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Fri, 30 May 2008 11:09:42 +0800
Message-ID: <483F6FF6.4060300@cn.fujitsu.com>
References: <48365CBF.4080502@cn.fujitsu.com> <20080529.033442.175635712.davem@davemloft.net> <6fe1847af5073e7f50519a2ebc730653@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59257 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbYE3DO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 23:14:26 -0400
In-Reply-To: <6fe1847af5073e7f50519a2ebc730653@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

samuel@sortiz.org said the following on 2006-1-21 14:07:
>>> 1. dma should be freed when dma2 request fail.
>>> 2. dma2 should be freed too when device close.
>>>
>>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> Jeff, did you get this or would you like me to pick
>> it up directly?
> I'll take it and send it along with my next IrDA patch set.
> 

oops, sorry. 
Seems that not all of the drivers/net/* fixes should be sent
to Jeff.
I will check MAINTAINERS more carefully next time.

--WCN

