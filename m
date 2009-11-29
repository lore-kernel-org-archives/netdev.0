From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/12] sfc: Allow for additional checksum offload
 features
Date: Sun, 29 Nov 2009 00:01:04 -0800 (PST)
Message-ID: <20091129.000104.109985484.davem@davemloft.net>
References: <1259422579.3709.12.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbZK2IA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:00:58 -0500
In-Reply-To: <1259422579.3709.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 28 Nov 2009 15:36:19 +0000

> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

You can add this patch when you actually have a chance in your
set that adds a value of ->offload_features other than NETIF_IP_CSUM.

So I'm setting aside this change for now, resubmit it along with
the change that actually needs to use different values.

Thanks.
