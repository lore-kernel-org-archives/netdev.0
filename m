From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: arp: Cleanup in arp.c
Date: Tue, 06 Dec 2011 00:35:06 -0500 (EST)
Message-ID: <20111206.003506.2005977183297723096.davem@davemloft.net>
References: <igorm@etf.rs>
	<1323087957-26429-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1LFFfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:35:12 -0500
In-Reply-To: <1323087957-26429-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: igorm@etf.rs
Date: Mon,  5 Dec 2011 13:25:57 +0100

> From: Igor Maravic <igorm@etf.rs>
> 
> Use "IS_ENABLED(CONFIG_FOO)" macro instead of
> "defined(CONFIG_FOO) || defined(CONFIG_FOO_MODULE)"
> 
> Signed-off-by: Igor Maravic <igorm@etf.rs>

Applied.
