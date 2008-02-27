From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ethtool netlink interface
Date: Tue, 26 Feb 2008 17:50:36 -0800 (PST)
Message-ID: <20080226.175036.256705356.davem@davemloft.net>
References: <20080225130456.GD20815@postel.suug.ch>
	<47C2FB1F.5090009@garzik.org>
	<20080225182343.GF20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756842AbYB0Btv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 20:49:51 -0500
In-Reply-To: <20080225182343.GF20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 25 Feb 2008 19:23:43 +0100

> * Jeff Garzik <jeff@garzik.org> 2008-02-25 12:30
> > However, I would think it inconsistent to only do SSET/GSET.  If others 
> > are OK with this patch, are you open to implementing the full set of 
> > ethtool operations?
> 
> Of course, I would also provide a documented userspace api within libnl.

I'm perfectly fine with all of this.
