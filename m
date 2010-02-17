From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/2] usbnet: Use (netdev|netif)_<level>
 macros
Date: Wed, 17 Feb 2010 13:54:08 -0800 (PST)
Message-ID: <20100217.135408.67924035.davem@davemloft.net>
References: <cover.1266438216.git.joe@perches.com>
	<20100217.133846.181531049.davem@davemloft.net>
	<1266443067.8446.179.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, gregkh@suse.de, tilman@imap.cc,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266443067.8446.179.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 17 Feb 2010 13:44:27 -0800

> On Wed, 2010-02-17 at 13:38 -0800, David Miller wrote:
>> 'allmodconfig' works well for build testing.  :-)
> 
> And takes ~6 hours on my netbook ;)

Takes ~6 minutes here :-)

Well, if you're making network device changes, having all of
the wired and wireless drivers enabled in your build is probably
a pretty good idea and should take only 1 hour on your laptop :)

A 6 fold increase!

> Do you know of an ssh-able test build system?

Besides the set of Niagara boxes I have here in my laundry room, no
sorry :-)
