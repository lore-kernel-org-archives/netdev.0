From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rps: fix the wrong network header pointer
Date: Sat, 21 Aug 2010 22:55:05 -0700 (PDT)
Message-ID: <20100821.225505.226791067.davem@davemloft.net>
References: <1282407208-3367-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751283Ab0HVFys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 01:54:48 -0400
In-Reply-To: <1282407208-3367-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 22 Aug 2010 00:13:28 +0800

> __skb_get_rxhash() was broken after the commit:
> 
>  commit bfb564e7391340638afe4ad67744a8f3858e7566
>  Author: Krishna Kumar <krkumar2@in.ibm.com>
>  Date:   Wed Aug 4 06:15:52 2010 +0000
> 
>  core: Factor out flow calculation from get_rps_cpu
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
