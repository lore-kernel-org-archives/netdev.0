From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [STABLE][3.0][3.2][Add PATCH] phy/fixed: use an unique MDIO bus
 name
Date: Mon, 08 Oct 2012 08:39:14 -0400
Message-ID: <1349699954.6755.110.camel@gandalf.local.home>
References: <1349441987.6755.45.camel@gandalf.local.home>
	 <1349624019.16173.113.camel@deadeye.wl.decadent.org.uk>
	 <20121007.145622.83624305358947187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, gregkh@linuxfoundation.org,
	florian@openwrt.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121007.145622.83624305358947187.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-10-07 at 14:56 -0400, David Miller wrote:

> But this change impacted a lot of MDIO drivers and there were
> regressions that needed to be fixed up the first time this stuff
> went in.

If it's that big of a deal then we can forget about this fix. I can get
around it if I tweak my config. Probably just skip the MDIO stuff.

-- Steve
