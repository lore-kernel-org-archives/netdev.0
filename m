From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Wed, 14 Nov 2007 02:18:55 -0800 (PST)
Message-ID: <20071114.021855.242406994.davem@davemloft.net>
References: <473AB82F.8050801@trash.net>
	<20071114094508.GA6004@mpi-sb.mpg.de>
	<473AC47B.9070509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rainer.jochem@mpi-sb.mpg.de, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pcernko@mpi-sws.mpg.de
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56420
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbXKNKS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 05:18:56 -0500
In-Reply-To: <473AC47B.9070509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 14 Nov 2007 10:48:43 +0100

> Rainer Jochem wrote:
> > 
> >> I don't think its very useful since you can simply get this information
> >> from /proc/cmdline in case something goes wrong, but if you insist at
> >> least give it a meaningful prefix.
> > 
> > Added.
> > 
> >> The initialization is unnecessary.
> > 
> > Removed.
> > 
> >> Should be >= I think.
> > 
> > Fixed.
> 
> Looks fine, thanks.

Applied to net-2.6.25, thanks everyone.
