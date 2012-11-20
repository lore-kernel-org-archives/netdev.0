From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Remove inet_lro remnants
Date: Mon, 19 Nov 2012 19:14:42 -0500 (EST)
Message-ID: <20121119.191442.1430422530127159786.davem@davemloft.net>
References: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752943Ab2KTAOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 19:14:43 -0500
In-Reply-To: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 16 Nov 2012 22:40:35 +0000

> Eric's comments on LRO/GRO conversion prompted me to check what was
> still using inet_lro.  Not very many drivers, but there are a few
> unnecessary references outside the code.

Series applied, thanks Ben.
