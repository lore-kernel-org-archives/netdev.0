From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 14 Apr 2008 16:03:09 -0700
Message-ID: <20080414230309.GA1672@kroah.com>
References: <20080414213238.GB28833@kroah.com> <20080414215905.GD16272@one-eyed-alien.net> <200804142342.08116.ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Dharm <mdharm-usb@one-eyed-alien.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Filip Aben <f.aben@option.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: "Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51774 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbYDNXDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 19:03:19 -0400
Content-Disposition: inline
In-Reply-To: <200804142342.08116.ajb@spheresystems.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 11:42:07PM +0100, Andrew Bird (Sphere Systems) wrote:
> Hi Matthew,
> 	I'd prefer the keep it as just 'hso' and change the textual description if 
> necessary. I think module names are just arbitrary, and should not 
> necessarily reflect the original usage too well, otherwise you end up with a 
> situation like with the 'option' module. That module is now used for many 
> devices from differing manufacturers and it doesn't really make much sense to 
> load the option module to service a device from Novatel, Sierra Wireless or 
> Huawei.

Ok, that's fine with me, what should we use for the text in the driver
and the Kconfig entry?

thanks,

greg k-h
