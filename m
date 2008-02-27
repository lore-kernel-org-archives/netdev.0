From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: Wed, 27 Feb 2008 13:58:49 -0800 (PST)
Message-ID: <20080227.135849.145717144.davem@davemloft.net>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
	<20080226.225104.175000479.davem@davemloft.net>
	<ygfhcfu85vt.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753836AbYB0V6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 16:58:50 -0500
In-Reply-To: <ygfhcfu85vt.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Urs Thuermann <urs@isnogud.escape.de>
Date: 27 Feb 2008 22:08:06 +0100

> David Miller <davem@davemloft.net> writes:
> 
> > I spent some time seriously considering this change but I
> > can't because it really can potentially break so much stuff.
> 
> Thanks for your time on this.  But AFAICS, the patch doesn't break
> libpcap.

Not libpcap in this case, but potentially other programs
might be effected by it.

Sorry.
