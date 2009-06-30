From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: xmit sctp packet always return no route error
Date: Mon, 29 Jun 2009 19:42:24 -0700 (PDT)
Message-ID: <20090629.194224.210551350.davem@davemloft.net>
References: <4A488021.50002@cn.fujitsu.com>
	<4A48BDD6.1020001@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbZF3CmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:42:18 -0400
In-Reply-To: <4A48BDD6.1020001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 29 Jun 2009 09:12:54 -0400

> Wei Yongjun wrote:
>> Commit 'net: skb->dst accessors'(adf30907d63893e4208dfe3f5c88ae12bc2f25d5)
>> broken the sctp protocol stack, the sctp packet can never be sent out after
>> Eric Dumazet's patch, which have typo in the sctp code.
>> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Oh-oh!!  Thanks for catching this.
> 
> Acked-by: Vlad Yasevich <vladisalv.yasevich@hp.com>

Applied.
