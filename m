From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Fix p3_gelic_net sparse warnings
Date: Fri, 22 Mar 2013 10:21:58 -0400 (EDT)
Message-ID: <20130322.102158.1484906038006332303.davem@davemloft.net>
References: <1363898133.1075.43.camel@smoke>
	<20130321.171723.2170130040090928680.davem@davemloft.net>
	<1363910819.1075.60.camel@smoke>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116Ab3CVOWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:22:00 -0400
In-Reply-To: <1363910819.1075.60.camel@smoke>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoff@infradead.org>
Date: Thu, 21 Mar 2013 17:06:59 -0700

> Rearrange routines to avoid local declarations and remove
> unnecessary inline tags.  No functional changes.
> 
> Fixes sparse warnings like these:
> 
>   ps3_gelic_net.c: error: marked inline, but without a definition
> 
> Signed-off-by: Geoff Levand <geoff@infradead.org>

This looks a lot better, applied, thanks Geoff.
