From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 27/33] sfc: Specify a meaningful component for loopback
 RX-side and PHY tests
Date: Fri, 12 Dec 2008 22:05:56 -0800 (PST)
Message-ID: <20081212.220556.205633037.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125733.GA10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755133AbYLMGFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:05:55 -0500
In-Reply-To: <20081212125733.GA10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:57:34 +0000

> Our ethtool self-test result names each begin with a component name.  For
> some results this is "port0", which is not very meaningful.  Change that
> to "rx" or "phy" as appropriate.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
