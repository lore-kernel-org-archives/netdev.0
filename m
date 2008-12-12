From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Micrel KS8695 integrated ethernet driver
Date: Thu, 11 Dec 2008 21:01:13 -0800 (PST)
Message-ID: <20081211.210113.179080588.davem@davemloft.net>
References: <1228843809.17317.34.camel@petitemort>
	<20081209.230535.161417535.davem@davemloft.net>
	<1228923679.5035.3.camel@ataraxia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: dsilvers@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750703AbYLLFBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:01:12 -0500
In-Reply-To: <1228923679.5035.3.camel@ataraxia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Silverstone <dsilvers@simtec.co.uk>
Date: Wed, 10 Dec 2008 15:41:19 +0000

> I've attached a driver which is the same as before but uses
> dma_mapping_error() to check the result.
> 
> I trust that this is the last issue :-)

Added to net-next-2.6, thanks Daniel.
