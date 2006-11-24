From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make udp_encap_rcv use pskb_may_pull
Date: Fri, 24 Nov 2006 13:35:47 -0800 (PST)
Message-ID: <20061124.133547.106434341.davem@davemloft.net>
References: <20061123000144.GB7452@suse.de>
	<20061122.201136.129449260.davem@davemloft.net>
	<200611241154.15740.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:20120
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S935079AbWKXVfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 16:35:37 -0500
To: netdev@axxeo.de
In-Reply-To: <200611241154.15740.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Fri, 24 Nov 2006 11:54:15 +0100

> Hi David,
> 
> David Miller wrote:
> > From: Olaf Kirch <okir@suse.de>
> > Date: Thu, 23 Nov 2006 01:01:44 +0100
> > 
> > > 
> > > Make udp_encap_rcv use pskb_may_pull
> > 
> > Excellent catch, applied, thanks Olaf.
> 
> Should this go to -stable, too? Or are these kernels not affected, yet?

I planned to push this to -stable over the weekend, but thanks for
reminding me anyways.
