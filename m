From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/33] sfc: Provide hints to irqbalance daemon
Date: Fri, 12 Dec 2008 21:37:14 -0800 (PST)
Message-ID: <20081212.213714.45567603.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212125229.GK10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754675AbYLMFhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:37:13 -0500
In-Reply-To: <20081212125229.GK10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:52:30 +0000

> Allocate IRQs with the name format <device>[-<type>]-<number> so that
> future versions of irqbalanced understand what we're doing.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks for doing this Ben.
