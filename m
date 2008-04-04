From: David Miller <davem@davemloft.net>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Fri, 04 Apr 2008 12:43:24 -0700 (PDT)
Message-ID: <20080404.124324.213993204.davem@davemloft.net>
References: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755258AbYDDTnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:43:23 -0400
In-Reply-To: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Fri, 4 Apr 2008 11:56:44 +0300 (EEST)

> 
> >> -     { 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
> 
> > applied
> 
> Hmm, did you see my yesterdays answer to that patch - that dmfe should 
> first be fixed to work on all  cards with this PCI ID? Currenty dmfe 
> fails to work on at least Sun Fire V100 and Sun Netra X1 boxes, only 
> tulip works.

Don't worry I won't pull from Jeff's tree until this issue is
resolved.
