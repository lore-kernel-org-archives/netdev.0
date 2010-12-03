From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 03/17] sfc: Distinguish critical and
 non-critical over-temperature conditions
Date: Fri, 03 Dec 2010 09:08:44 -0800 (PST)
Message-ID: <20101203.090844.71121110.davem@davemloft.net>
References: <1291333490.3259.23.camel@bwh-desktop>
	<1291333584.3259.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752145Ab0LCRIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:08:17 -0500
In-Reply-To: <1291333584.3259.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Dec 2010 23:46:24 +0000

> Set both the 'maximum' and critical temperature limits for LM87
> hardware monitors on Falcon boards.  Do not shut down a port until the
> critical temperature is reached, but warn as soon as the 'maximum'
> temperature is reached.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
