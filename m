From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] forcedeth: remove mgmt unit for mcp79 chipset
Date: Fri, 09 Jan 2009 23:12:49 -0800 (PST)
Message-ID: <20090109.231249.107468579.davem@davemloft.net>
References: <4967BB9D.6020006@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbZAJHMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:12:48 -0500
In-Reply-To: <4967BB9D.6020006@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 09 Jan 2009 16:03:25 -0500

> This patch removes the feature flag for mgmt unit as it is not used for this chipset.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

I had to apply this patch by hand, these tables look different
right now.
