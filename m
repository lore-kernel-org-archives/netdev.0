From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] sfc: Improve NIC internal error recovery
Date: Wed, 04 Mar 2009 17:55:52 -0800 (PST)
Message-ID: <20090304.175552.06158111.davem@davemloft.net>
References: <1236196272.3140.15.camel@achroite>
	<1236196917.3140.34.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753990AbZCEB4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 20:56:07 -0500
In-Reply-To: <1236196917.3140.34.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 04 Mar 2009 20:01:57 +0000

> Make the error count a per-NIC variable.
> Reset this the count after an hour if it has not reached the critical value.
> Set the critical value back to 5.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
