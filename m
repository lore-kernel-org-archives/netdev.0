From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] sfc: When disabling the NIC, close the device
 rather than unregistering it
Date: Fri, 26 Dec 2008 13:48:57 -0800 (PST)
Message-ID: <20081226.134857.176245420.davem@davemloft.net>
References: <1230176541.3401.51.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753176AbYLZVsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:48:54 -0500
In-Reply-To: <1230176541.3401.51.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 25 Dec 2008 03:42:21 +0000

> This should reduce user confusion and may also aid recovery (ioctls
> will still be available).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
