From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: remove outdated comment for ipv4 and
 ipv6 protocol handler
Date: Thu, 28 Nov 2013 18:48:07 -0500 (EST)
Message-ID: <20131128.184807.1872121178374313062.davem@davemloft.net>
References: <1385365686-17804-1-git-send-email-baker.kernel@gmail.com>
	<1385429355-21442-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3K1XsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:48:09 -0500
In-Reply-To: <1385429355-21442-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: baker.kernel@gmail.com
Date: Tue, 26 Nov 2013 09:29:15 +0800

> From: Baker Zhang <Baker.kernel@gmail.com>
> 
> since f9242b6b28d61295f2bf7e8adfb1060b382e5381
> inet: Sanitize inet{,6} protocol demux.
> 
> there are not pretended hash tables for ipv4 or
> ipv6 protocol handler.
> 
> Signed-off-by: Baker Zhang <Baker.kernel@gmail.com>

Applied, thanks.
