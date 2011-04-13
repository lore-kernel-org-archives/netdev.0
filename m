From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] net: Disable NETIF_F_TSO_ECN when TSO is
 disabled
Date: Tue, 12 Apr 2011 19:30:00 -0700 (PDT)
Message-ID: <20110412.193000.104043990.davem@davemloft.net>
References: <1302655117.2880.33.camel@bwh-desktop>
	<1302655635.2880.35.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437Ab1DMCaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 22:30:35 -0400
In-Reply-To: <1302655635.2880.35.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Apr 2011 01:47:15 +0100

> NETIF_F_TSO_ECN has no effect when TSO is disabled; this just means
> that feature state will be accurately reported to user-space.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
