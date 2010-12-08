From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fixing LRO configuration
Date: Wed, 08 Dec 2010 12:19:24 -0800 (PST)
Message-ID: <20101208.121924.35033302.davem@davemloft.net>
References: <1291833849.2560.26.camel@bwh-desktop>
	<1291834280-30787-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754171Ab0LHUS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:18:57 -0500
In-Reply-To: <1291834280-30787-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Wed,  8 Dec 2010 16:51:20 -0200

> In order to set LRO on ehea, the user must set a module parameter, which
> is not the standard way to do so. This patch adds a way to set LRO using
> the ethtool tool.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks Breno.
