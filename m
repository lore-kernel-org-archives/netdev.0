From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/33] sfc: Implement auto-negotiation
Date: Fri, 12 Dec 2008 21:50:55 -0800 (PST)
Message-ID: <20081212.215055.178266362.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125509.GT10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44219
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754938AbYLMFuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:50:54 -0500
In-Reply-To: <20081212125509.GT10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:55:10 +0000

> Add infrastructure for auto-negotiation of speed, duplex and flow
> control.
> 
> When using 10Xpress, auto-negotiate flow control.  While we're
> at it, clean up the code to warn when partner is not 10GBASE-T
> capable.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
