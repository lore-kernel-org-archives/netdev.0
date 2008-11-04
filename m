From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: net/: Kill now superfluous ->last_rx stores.
Date: Mon, 03 Nov 2008 23:07:28 -0800 (PST)
Message-ID: <20081103.230728.114892337.davem@davemloft.net>
References: <20081103.220145.73307270.davem@davemloft.net>
	<EA788924-7447-4877-B68B-48F4E66C3B55@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752028AbYKDHHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 02:07:53 -0500
In-Reply-To: <EA788924-7447-4877-B68B-48F4E66C3B55@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 4 Nov 2008 07:14:59 +0100

> > net/: Kill now superfluous ->last_rx stores.
> >
> > The generic packet receive code takes care of setting
> > netdev->last_rx when necessary, for the sake of the
> > bonding ARP monitor.
> >
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> just for the sake of it, the Bluetooth part is fine with :)
> 
> Acked-by: Marcel Holtmann <marcel@holtmann.org>

Thanks for looking at it Marcel :)
