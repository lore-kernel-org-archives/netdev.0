From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 24/33] sfc: Fix format arguments for warning about
 MSI-X allocation
Date: Fri, 12 Dec 2008 21:25:50 -0800 (PST)
Message-ID: <20081212.212550.225703824.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212125637.GX10372@solarflare.com>
	<1229114087.3051.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbYLMFZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:25:48 -0500
In-Reply-To: <1229114087.3051.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 20:34:47 +0000

> I thought this warning was already present, but it is actually
> introduced by patch 10/33.  There's no point in introducing it wrongly,
> so please combine the two.  Or I can post the combined patch myself.

I'll take care of this, thanks Ben.
