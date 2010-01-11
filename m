From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation/3c509: document ethtool support
Date: Mon, 11 Jan 2010 15:53:53 -0800 (PST)
Message-ID: <20100111.155353.98060652.davem@davemloft.net>
References: <1263253429.3852.5.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459Ab0AKXxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 18:53:45 -0500
In-Reply-To: <1263253429.3852.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 11 Jan 2010 23:43:49 +0000

> 3c509 was changed to support ethtool in 2002, making the 'xcvr' module
> parameter obsolete in most cases.  More recently 3c509 was converted
> to the modern driver model and this parameter was removed.  Fix the
> documentation to refer to ethtool rather than the module parameter.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks.
