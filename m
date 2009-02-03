From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] s2io: Formatting log message
Date: Tue, 03 Feb 2009 15:15:22 -0800 (PST)
Message-ID: <20090203.151522.87565991.davem@davemloft.net>
References: <49883B07.9030009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sreenivasa.honnur@neterion.com, jeff@garzik.org,
	netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751677AbZBCXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 18:15:25 -0500
In-Reply-To: <49883B07.9030009@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Tue, 03 Feb 2009 10:39:35 -0200

> S2IO driver is printing dev->name before the name being allocated, which
> display eth%d instead of eth0, eth1, etc. Example: 
> 
> eth%d: Enabling MSIX failed
> eth%d: MSI-X requested but failed to enable
> 
> This patch just change eth%d to s2io.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
