From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix driver name for mdio-gpio.c
Date: Thu, 20 Oct 2011 17:48:07 -0400 (EDT)
Message-ID: <20111020.174807.1345631716931276111.davem@davemloft.net>
References: <1318943051-22432-1-git-send-email-eibach@gdsys.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	grant.likely@secretlab.ca
To: eibach@gdsys.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318943051-22432-1-git-send-email-eibach@gdsys.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dirk Eibach <eibach@gdsys.de>
Date: Tue, 18 Oct 2011 15:04:11 +0200

> Since commit
> "7488876... dt/net: Eliminate users of of_platform_{,un}register_driver"
> there are two platform drivers named "mdio-gpio" registered.
> I renamed the of variant to "mdio-ofgpio".
> 
> Signed-off-by: Dirk Eibach <eibach@gdsys.de>

Applied, thanks.
