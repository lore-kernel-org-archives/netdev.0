From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] at91_ether: Do not select NET_CORE
Date: Wed, 19 Jun 2013 22:23:49 -0700 (PDT)
Message-ID: <20130619.222349.827686632903657126.davem@davemloft.net>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
	<1371522449.3495.65.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com, manabian@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab3FTFXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:23:49 -0400
In-Reply-To: <1371522449.3495.65.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 18 Jun 2013 03:27:29 +0100

> This has no dependency on any of the drivers under NET_CORE.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
