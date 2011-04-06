From: David Miller <davem@davemloft.net>
Subject: Re: NETIF_F_TSO vs NETIF_F_TSO{6,_ECN}
Date: Wed, 06 Apr 2011 14:22:58 -0700 (PDT)
Message-ID: <20110406.142258.27795713.davem@davemloft.net>
References: <1302018602.2932.22.camel@bwh-desktop>
	<20110405180337.GA16977@rere.qmqm.pl>
	<1302028298.2932.76.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53930
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756867Ab1DFVXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:23:34 -0400
In-Reply-To: <1302028298.2932.76.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 05 Apr 2011 19:31:38 +0100

> *sigh*  So it seems the commit message was wrong... and it should have
> included a change like this:

This seems correct, can you formally submit this fix?

Thanks.
