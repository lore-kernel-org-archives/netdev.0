From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdev: Update status of 8390 based drivers
 in MAINTAINERS
Date: Mon, 03 Jan 2011 11:06:55 -0800 (PST)
Message-ID: <20110103.110655.115926709.davem@davemloft.net>
References: <1293924510-14290-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752511Ab1ACTGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:06:23 -0500
In-Reply-To: <1293924510-14290-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat,  1 Jan 2011 18:28:30 -0500

> With the original 8 bit ISA ne1000 card being over 20 years old, it
> only makes sense to consider ne.c and all the other toplevel 8390
> based driver files as legacy for obsolete hardware.  The most
> recent thing made in large quantities that was 8390 based were
> those crazy PCI ne2k clones - and even they are now 10+ years old.
> 
> Also remove myself as maintainer, since the only changes to these
> drivers going forward will be the generic API type changes that
> touch all drivers.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Also applied, thanks Paul.
