From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Tue, 22 Jan 2013 13:58:47 -0500 (EST)
Message-ID: <20130122.135847.466818986790360986.davem@davemloft.net>
References: <1358762966-20791-21-git-send-email-thierry.reding@avionic-design.de>
	<20130121.152913.1377695352860141642.davem@davemloft.net>
	<20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org,
	dmitry.torokhov@gmail.com, arnd@arndb.de, w.sang@pengutronix.de,
	netdev@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Tue, 22 Jan 2013 07:56:29 +0100

> I planned to do so initially, but that yielded a Cc list of 156 people
> and mailing lists,

Just use mailing lists, the individuals are subscribed to the subsystem
lists that cover what they maintain.

Yes, CC:'ing 156 "people" is stupid.
