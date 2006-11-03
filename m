From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Thu, 2 Nov 2006 18:47:15 -0800
Message-ID: <200611021847.21817.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200611021229.17324.david-b@pacbell.net> <20061103022726.GF13381@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Randy Dunlap <randy.dunlap@oracle.com>,
	toralf.foerster@gmx.de, netdev@vger.kernel.org,
	linux-usb-devel@lists.sourceforge.net, link@miggy.org,
	akpm@osdl.org, zippel@linux-m68k.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.sbc.mail.mud.yahoo.com ([68.142.198.204]:13695 "HELO
	smtp105.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1752989AbWKCCre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 21:47:34 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061103022726.GF13381@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 November 2006 6:27 pm, Adrian Bunk wrote:

> It seems to lack the "select MII" at the USB_RTL8150 option that was in 
> Randy's first patch?

I was just addressing the usbnet issues ... that driver doesn't
use the usbnet framework.

- Dave
