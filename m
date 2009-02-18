From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 26/43] drivers/net/sfc: fix sparse warning: symbol
 shadows an earlier one
Date: Tue, 17 Feb 2009 17:39:32 -0800 (PST)
Message-ID: <20090217.173932.176817674.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214213932.24377.94262.stgit@vmbox.hanneseder.net>
	<20090216003820.GO15266@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756146AbZBRBjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:39:48 -0500
In-Reply-To: <20090216003820.GO15266@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 16 Feb 2009 00:38:20 +0000

> Hannes Eder wrote:
> > Impact: Move variable declaration as close to their usage as possible.
> > 
> > Fix this sparse warning:
> >   drivers/net/sfc/tenxpress.c:589:22: warning: symbol 'link_ok' shadows an earlier one
> >   drivers/net/sfc/tenxpress.c:575:30: originally declared here
> > 
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
