From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] typhoon: replace users of __constant_{endian}
Date: Sun, 18 Jan 2009 22:23:13 -0800 (PST)
Message-ID: <20090118.222313.135296911.davem@davemloft.net>
References: <1232075884.1502.0.camel@obelisk.thedillows.org>
	<20090118.220310.122867092.davem@davemloft.net>
	<1232345958.5570.6.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, jeff@garzik.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758210AbZASGXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:23:11 -0500
In-Reply-To: <1232345958.5570.6.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sun, 18 Jan 2009 22:19:18 -0800

> On Sun, 2009-01-18 at 22:03 -0800, David Miller wrote:
> > From: David Dillow <dave@thedillows.org>
> > Date: Thu, 15 Jan 2009 22:18:04 -0500
> > 
> > > On Thu, 2009-01-15 at 16:41 -0800, Harvey Harrison wrote:
> > > > The base versions handle constant folding just fine, use them
> > > > directly.
> > > > 
> > > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > > Acked-by: David Dillow <dave@thedillows.org>
> > 
> > Applied for 2.6.30, thanks everyone.
> 
> Dave, I split out typhoon as it had the most uses of the __constant_
> versions, the other net drivers have only a handful each, should I
> bother splitting that one up, or would you be OK with an omnibus
> patch?

Omnibus is fine.
