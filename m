From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 08:40:32 -0700
Message-ID: <20080415154032.GD7996@kroah.com>
References: <20080414213238.GB28833@kroah.com> <20080414215905.GD16272@one-eyed-alien.net> <200804142342.08116.ajb@spheresystems.co.uk> <20080414230309.GA1672@kroah.com> <alpine.DEB.0.99.0804150951100.6062@FWR-FLAB>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>,
	Matthew Dharm <mdharm-usb@one-eyed-alien.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: Filip Aben <f.aben@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57516 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764570AbYDOPvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 11:51:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.99.0804150951100.6062@FWR-FLAB>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 10:01:14AM +0200, Filip Aben wrote:
>
> "
> This driver is used for Option HSDPA/HSUPA cards that support
> downlink speeds of 7.2Mbps or greater.
> "
>
> How does that sound ?

Sounds good, I've updated the Kconfig entry with it.

thanks,

greg k-h
