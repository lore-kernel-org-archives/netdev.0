From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Remove lro module parameter
Date: Tue, 19 May 2009 16:19:16 -0700 (PDT)
Message-ID: <20090519.161916.230120990.davem@davemloft.net>
References: <1242775077.3198.4.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57708
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754797AbZESXTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 19:19:18 -0400
In-Reply-To: <1242775077.3198.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 20 May 2009 00:17:57 +0100

> GRO/LRO can be controlled through ethtool so this is unnecessary.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6, thanks!
