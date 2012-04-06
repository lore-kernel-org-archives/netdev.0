From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Documentation fixes
Date: Fri, 06 Apr 2012 02:43:33 -0400 (EDT)
Message-ID: <20120406.024333.2063598126722690725.davem@davemloft.net>
References: <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2DFGng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 02:43:36 -0400
In-Reply-To: <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 6 Apr 2012 01:37:47 +0100

> These changes update Documentation/networking/driver.txt and
> Documentation/networking/netdevices.txt to reflect the last 5 or so
> years of API changes (though no new features are documented).
> 
> They also remove documentation of a wrinkle in ethtool_ops that I
> recently fixed.
> 
> These could safely be applied to either net or net-next; they can't
> break anything but another 3 months of dust isn't going to make much
> difference.

Thanks for doing this work Ben, I've applied it all to 'net'.
