From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V3 net-next 0/2] usbnet: Use (netdev|netif)_<level>
 macros
Date: Wed, 17 Feb 2010 13:44:27 -0800
Message-ID: <1266443067.8446.179.camel@Joe-Laptop.home>
References: <20100217.000422.246530855.davem@davemloft.net>
	 <cover.1266438216.git.joe@perches.com>
	 <20100217.133846.181531049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, gregkh@suse.de, tilman@imap.cc,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1046 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757212Ab0BQVo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 16:44:29 -0500
In-Reply-To: <20100217.133846.181531049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 13:38 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 17 Feb 2010 12:30:22 -0800
> > Sorry 'bout that.
> > I'll try to improve my insufficient grep and build testing.
> 'allmodconfig' works well for build testing.  :-)

And takes ~6 hours on my netbook ;)

I try to avoid it.
Do you know of an ssh-able test build system?

cheers, Joe

