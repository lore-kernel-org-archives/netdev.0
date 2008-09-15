From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 15:11:25 -0700 (PDT)
Message-ID: <20080915.151125.93659986.davem@davemloft.net>
References: <20080915204543.GD3994@havoc.gtf.org>
	<20080915.141442.139271313.davem@davemloft.net>
	<20080915215307.GA10340@alpha.franken.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tsbogend@alpha.franken.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756072AbYIOWLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 18:11:31 -0400
In-Reply-To: <20080915215307.GA10340@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Date: Mon, 15 Sep 2008 23:53:08 +0200

> On Mon, Sep 15, 2008 at 02:14:42PM -0700, David Miller wrote:
> > Most of those changes were complete and utter CRAP.
> 
> thank you, but the fix I've sent (de2104x) isn't crap. The bug breaks the 
> current debian-installer for Cobalt Qube1, when it tries to get an
> IP address via dhcp. 

And why is this bug that has been there for YEARS is appropriate
to fix outside of the merge window?

> In my eyes it's a clean and good fix,

There are a lot of clean and good fixes, but that is not the
criteria for outside-of-the merge-window submissions right now.

Linus has made this clear.
