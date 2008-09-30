From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: docbook comment update (revised)
Date: Tue, 30 Sep 2008 02:24:41 -0700 (PDT)
Message-ID: <20080930.022441.32388035.davem@davemloft.net>
References: <Pine.LNX.4.64.0809230917020.27041@shark.he.net>
	<20080923100240.5168d861@extreme>
	<Pine.LNX.4.64.0809231010280.27041@shark.he.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751729AbYI3JYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 05:24:52 -0400
In-Reply-To: <Pine.LNX.4.64.0809231010280.27041@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Randy.Dunlap" <rdunlap@xenotime.net>
Date: Tue, 23 Sep 2008 10:12:04 -0700 (PDT)

> On Tue, 23 Sep 2008, Stephen Hemminger wrote:
> 
> > +/**
> > + *	dev_get_flags - get flags reported to userspace
> > + *	@dev: device
> > + *
> > + *	Get the combination of flag bits exported throug APIs to userspace.
> 
> 
> still needs:                                      through

I've applied Stephen's patch with this fix.
