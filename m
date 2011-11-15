From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] IPv6: Removing unnecessary NULL checks
 introduced in 4a287eba2de395713d8b2b2aeaa69fa086832d34.
Date: Tue, 15 Nov 2011 16:55:33 -0500 (EST)
Message-ID: <20111115.165533.85188071326137725.davem@davemloft.net>
References: <1321354739.1858.72.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757400Ab1KOVzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:55:39 -0500
In-Reply-To: <1321354739.1858.72.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Tue, 15 Nov 2011 12:58:59 +0200

> This patch removes unnecessary NULL checks noticed by Dan Carpenter.
> Checks were introduced in commit
> 4a287eba2de395713d8b2b2aeaa69fa086832d34 to net-next.
> 
> Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

Applied.

I took the commit ID reference out of the subject line, that is generally
considered bad form.
