From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] NET_SCHED: Rate table fixes
Date: Wed, 12 Sep 2007 07:37:49 -0700 (PDT)
Message-ID: <20070912.073749.77044069.davem@davemloft.net>
References: <1189592020.26927.20.camel@localhost.localdomain>
	<46E7C54F.4040208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:42802
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S969112AbXILOh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:37:57 -0400
In-Reply-To: <46E7C54F.4040208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 12 Sep 2007 12:54:07 +0200

> Jesper Dangaard Brouer wrote:
> > This set of patches, aim at fixing an issue with the rate table used
> > by the rate based schedulers.
> 
> 
> ACK for all the patches :)

I added the two kernel patches to net-2.6.24, thanks!
