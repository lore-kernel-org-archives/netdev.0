From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 19 Sep 2006 18:10:17 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0609191808470.24069@blysk.ds.pg.gda.pl>
References: <E1GPflG-0000n7-2o@lucciola> <Pine.LNX.4.64N.0609191441260.24069@blysk.ds.pg.gda.pl>
 <45101EC1.7040407@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amy Fong <amy.fong@windriver.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030336AbWISRKT@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45101EC1.7040407@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006, Jeff Garzik wrote:

> >  And sb1250-mac.c would be happy to use it too.
> 
> "would be happy to" != "is using".   I don't want to add a phy driver until
> there are already active users in the kernel.

 Fair enough, but Amy may be looking forward to seeing yet another piece 
of code using the new driver. ;-)

  Maciej
