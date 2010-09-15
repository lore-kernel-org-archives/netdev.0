From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next-2.6 1/2] ethtool: Complete kernel-doc
 comments for RX flow filter and hash control
Date: Wed, 15 Sep 2010 14:42:01 -0700 (PDT)
Message-ID: <20100915.144201.45897638.davem@davemloft.net>
References: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	santwona.behera@sun.com, peter.p.waskiewicz.jr@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754286Ab0IOVln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:41:43 -0400
In-Reply-To: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 14 Sep 2010 20:10:03 +0100

> There are now several interfaces within the ethtool API for getting
> and setting RX flow filtering and hashing behaviour, most of which are
> poorly documented.  This adds kernel-doc comments for all these
> interfaces, based on the existing incomplete comments and on the
> initial implementations.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

I'll apply this too, thanks Ben.
