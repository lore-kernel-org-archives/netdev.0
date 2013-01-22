From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Tue, 22 Jan 2013 13:17:54 +0000
Message-ID: <201301221317.55097.arnd@arndb.de>
References: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de> <201301221303.06785.arnd@arndb.de> <20130122130957.GA18165@avionic-0098.adnet.avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	w.sang@pengutronix.de, netdev@vger.kernel.org
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122130957.GA18165@avionic-0098.adnet.avionic-design.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 January 2013, Thierry Reding wrote:
> > I've had the same problem a couple of times. The best compromise seems
> > to be to Cc only the top-level subsystem maintainers and mailing lists
> > on the first email.
> 
> Even that would have been about 50 addresses IIRC. But perhaps that's
> still the best compromise to avoid any confusion.

Be careful though that the Cc list must not exceed 1024 characters or
it will get rejected by some of the mailing list servers.

	Arnd
