From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Thu, 2 Nov 2006 18:58:54 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0611021858140.16878@shark.he.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org>
 <200611021229.17324.david-b@pacbell.net> <20061103022726.GF13381@stusta.de>
 <200611021847.21817.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Adrian Bunk <bunk@stusta.de>, Greg KH <greg@kroah.com>,
	Randy Dunlap <randy.dunlap@oracle.com>, toralf.foerster@gmx.de,
	netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	link@miggy.org, akpm@osdl.org, zippel@linux-m68k.org,
	torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:63700 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1752998AbWKCC66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 21:58:58 -0500
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 2 Nov 2006 18:58:55 -0800
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200611021847.21817.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006, David Brownell wrote:

> On Thursday 02 November 2006 6:27 pm, Adrian Bunk wrote:
>
> > It seems to lack the "select MII" at the USB_RTL8150 option that was in
> > Randy's first patch?
>
> I was just addressing the usbnet issues ... that driver doesn't
> use the usbnet framework.

and Randy is away for a few days with very limited net access.

-- 
~Randy
