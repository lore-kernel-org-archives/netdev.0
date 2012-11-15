From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: convert __IPTUNNEL_XMIT() to an
 inline function
Date: Wed, 14 Nov 2012 20:25:28 -0500 (EST)
Message-ID: <20121114.202528.1105912458874607239.davem@davemloft.net>
References: <1352706754-16594-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992503Ab2KOBZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 20:25:29 -0500
In-Reply-To: <1352706754-16594-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 12 Nov 2012 15:52:33 +0800

> __IPTUNNEL_XMIT() is an ugly macro, convert it to a static
> inline function, so make it more readable.
> 
> IPTUNNEL_XMIT() is unused, just remove it.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
