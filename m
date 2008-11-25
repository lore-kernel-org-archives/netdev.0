From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: generate kobject uevent on network events.
Date: Tue, 25 Nov 2008 00:39:33 -0800 (PST)
Message-ID: <20081125.003933.264893964.davem@davemloft.net>
References: <20081124114522.1e8de3fe@extreme>
	<ac3eb2510811241155h4f51784cgf44d2e3d7ae807b8@mail.gmail.com>
	<20081124120645.417ea6e7@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, marcel@holtmann.org,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20081124120645.417ea6e7@extreme>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 24 Nov 2008 12:06:45 -0800

> On Mon, 24 Nov 2008 20:55:02 +0100
> "Kay Sievers" <kay.sievers@vrfy.org> wrote:
> 
> > Did you do anything else to prevent the duplicated add/remove events?
> > The core does send these already. I replied with a "udevadm monitor"
> > output to your earlier mail. Don't you see the duplicates on your box?
> > 
> > Thanks,
> > Kay
> 
> okay, then i'll just take it out of here.

I'll wait for the updated patch then.
