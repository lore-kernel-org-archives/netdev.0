From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 05 Dec 2013 13:36:58 -0500 (EST)
Message-ID: <20131205.133658.1284215652394971811.davem@davemloft.net>
References: <7F44EA5110810A40B7DAFB605C41975D2C96279B@CMEXMB1.ad.emulex.com>
	<20131205.012813.2201475304685818121.davem@davemloft.net>
	<1386259125.1516.115.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Somnath.Kotur@Emulex.Com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3LEShF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 13:37:05 -0500
In-Reply-To: <1386259125.1516.115.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 5 Dec 2013 15:58:45 +0000

> It seems like it would be useful to expose the real state of the
> hardware filter to userland - just not through log messages.

This is what I meant.
