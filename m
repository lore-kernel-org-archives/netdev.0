From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: minor netns related cleanup
Date: Thu, 01 Apr 2010 18:43:06 -0700 (PDT)
Message-ID: <20100401.184306.130496171.davem@davemloft.net>
References: <20100326.201426.05866973.davem@davemloft.net>
	<20100331024354.GA6631@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758974Ab0DBBnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:43:05 -0400
In-Reply-To: <20100331024354.GA6631@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Goff <thomas.goff@boeing.com>
Date: Tue, 30 Mar 2010 19:43:54 -0700

> These changes were suggested by Alexey Dobriyan <adobriyan@gmail.com>:
> 
>   - psched_show() does not use any private data so just pass NULL to
>     psched_open()
> 
>   - remove unnecessary return statement
> 
> Signed-off-by: Tom Goff <thomas.goff@boeing.com>

Applied.
