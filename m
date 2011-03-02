From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] net: dcbnl: check correct ops in
 dcbnl_ieee_set()
Date: Wed, 02 Mar 2011 15:05:17 -0800 (PST)
Message-ID: <20110302.150517.70181584.davem@davemloft.net>
References: <20110302203533.2465.11134.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulikr@broadcom.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757454Ab1CBXEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 18:04:40 -0500
In-Reply-To: <20110302203533.2465.11134.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Wed, 02 Mar 2011 12:35:33 -0800

> The incorrect ops routine was being tested for in
> DCB_ATTR_IEEE_PFC attributes. This patch corrects
> it.
> 
> Currently, every driver implementing ieee_setets also
> implements ieee_setpfc so this bug is not actualized
> yet.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
