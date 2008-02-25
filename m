From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ethtool netlink interface
Date: Mon, 25 Feb 2008 19:23:43 +0100
Message-ID: <20080225182343.GF20815@postel.suug.ch>
References: <20080225130456.GD20815@postel.suug.ch> <47C2FB1F.5090009@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47715 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284AbYBYSXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 13:23:23 -0500
Content-Disposition: inline
In-Reply-To: <47C2FB1F.5090009@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jeff Garzik <jeff@garzik.org> 2008-02-25 12:30
> However, I would think it inconsistent to only do SSET/GSET.  If others 
> are OK with this patch, are you open to implementing the full set of 
> ethtool operations?

Of course, I would also provide a documented userspace api within libnl.
