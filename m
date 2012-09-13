From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: Compare addresses only bits up to the prefix
 length (RFC6724).
Date: Thu, 13 Sep 2012 16:34:56 -0400 (EDT)
Message-ID: <20120913.163456.554273298808557600.davem@davemloft.net>
References: <201209110508.q8B58Min015633@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478Ab2IMUe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:34:57 -0400
In-Reply-To: <201209110508.q8B58Min015633@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 11 Sep 2012 13:41:07 +0900

> Compare bits up to the source address's prefix length only to
> allows DNS load balancing to continue to be used as a tie breaker.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-next
