From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: add netdev to ATM
Date: Sun, 30 Nov 2008 23:27:19 -0800 (PST)
Message-ID: <20081130.232719.56970907.davem@davemloft.net>
References: <20081129.204341.88799313.davem@davemloft.net>
	<1228033389-24415-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50657
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750740AbYLAH1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 02:27:19 -0500
In-Reply-To: <1228033389-24415-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Sun, 30 Nov 2008 09:23:09 +0100

> David Miller wrote:
> > > One fail path in hrz_probe omitted device disable. Fix it.
> > > 
> > > Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> > 
> > Applied, but please post all networking patches to
> > netdev@vger.kernel.org, in particular so that they
> > get properly tracked at:
> > 
> > 	http://patchwork.ozlabs.org/project/netdev/list/
> > 
> > I feel like I type this in at least 10 times a day, so
> > people please start making sure netdev is on the CC: for
> > all networking patches.
> 
> Hmm, I didn't even think this is net related. I would expect such things to
> be in drivers/net/ then. Consider the patch below for applying.
> 
> --
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied, thanks Jiri!
