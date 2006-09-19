From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 19 Sep 2006 14:43:55 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0609191441260.24069@blysk.ds.pg.gda.pl>
References: <E1GPflG-0000n7-2o@lucciola>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:46343 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1751243AbWISNn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 09:43:56 -0400
To: Amy Fong <amy.fong@windriver.com>
In-Reply-To: <E1GPflG-0000n7-2o@lucciola>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006, Amy Fong wrote:

> > And... where are the users of this phy driver?
[...]
> This phy driver is used by the WRS's sbc8560 (bcm5421s) and sbc843x 
> (bcm5461s) via the gianfar driver.

 And sb1250-mac.c would be happy to use it too.

  Maciej
