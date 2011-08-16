From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] ethtool: Note common alternate exit
 condition for interrupt coalescing
Date: Tue, 16 Aug 2011 16:36:59 -0700 (PDT)
Message-ID: <20110816.163659.936718420710720425.davem@davemloft.net>
References: <1313453180.2731.57.camel@bwh-desktop>
	<1313453362.2731.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eli@dev.mellanox.co.il
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1HPXhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 19:37:04 -0400
In-Reply-To: <1313453362.2731.61.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 16 Aug 2011 01:09:22 +0100

> Many implementations ignore the value of max_frames and do not
> treat usecs == 0 as special.  Document this as deprecated.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
