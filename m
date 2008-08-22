From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 10:43:23 -0700
Message-ID: <20080822174323.GB2551@susedev.qlogic.org>
References: <20080821185402.GD31526@susedev.qlogic.org> <20080821194802.GR7908@solarflare.com> <48AE8363.8090508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, Linux-Driver@qlogic.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12959 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbYHVRn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 13:43:56 -0400
Content-Disposition: inline
In-Reply-To: <48AE8363.8090508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 05:14:11AM -0400, Jeff Garzik wrote:
> Ben Hutchings wrote:
> >Ron Mercer wrote:
> >>Hi Jeff,
> >>
> >>Please find our new 10Gb ethernet driver at the following site:
> >>
> >>ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge
> >>
> >>There are two files at this location:
> >>qlge-aug212008.patch - A full patch that is buildable on the latest 
> >>netdev/upstream kernel.
> >>qlge-aug212008.tar.bz2 - A zip file of the source code at 
> >>drivers/net/qlge/*
> >>
> >>We are targeting this driver for 2.6.28 release.  We look forward to any 
> >>and all comments.
> >[...]
> >
> >Can you break up the patch into logical chunks and post them to netdev?
> >(The message limit is 100 K.)
> 
> Actually, the limit was raised from 100k to 400k.  Given that the qlogic 
> patch is 209k, it should be postable as is.
> 
> 	Jeff
>

Excellent news.  I will post a patch series later today.  I will break
out ethtool as it's going to grow with reg dump etc...

 
> 
> 
