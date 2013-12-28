From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arp: make arp_invalidate static
Date: Sat, 28 Dec 2013 17:03:04 -0500 (EST)
Message-ID: <20131228.170304.823077122882232791.davem@davemloft.net>
References: <20131228110718.256a8711@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3L1WDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 17:03:06 -0500
In-Reply-To: <20131228110718.256a8711@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 28 Dec 2013 11:07:18 -0800

> Don't export arp_invalidate, only used in arp.c
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
