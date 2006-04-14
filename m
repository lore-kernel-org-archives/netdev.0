From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [stable] [PATCH 1/4] clip: run through Lindent
Date: Fri, 14 Apr 2006 02:01:21 -0700 (PDT)
Message-ID: <20060414.020121.56547342.davem@davemloft.net>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<20060413152224.2d46df99@localhost.localdomain>
	<20060413224529.GA2476@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22502
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965123AbWDNJBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 05:01:20 -0400
To: greg@kroah.com
In-Reply-To: <20060413224529.GA2476@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Thu, 13 Apr 2006 15:45:29 -0700

> On Thu, Apr 13, 2006 at 03:22:24PM -0700, Stephen Hemminger wrote:
> > Run CLIP driver through Lindent script to fix formatting.
> 
> That's well and good, but really not a -stable thing.  In fact, I don't
> see any of these 4 patches being -stable material, do you?

Me neither.

Stephen please don't push patches into -stable until they've
been fully reviewed and integrated into Linus's tree first.

Please let me do my job as networking maintainer and let the
netdev list do it's job in reviewing your changes before they
go in.

Thanks.
