From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 18:33:57 -0500 (EST)
Message-ID: <20140213.183357.2022405581708903362.davem@davemloft.net>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaBMXd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:33:58 -0500
In-Reply-To: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 12 Feb 2014 20:51:22 -0800

> One of my pet coding style peeves is the practice of
> adding extra return; at the end of function.
> Kill several instances of this in network code.
> 
> I suppose some coccinelle wizardy could do this automatically.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

These are all straight-forward cases, applied, thanks.
