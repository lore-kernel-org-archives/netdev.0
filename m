From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Fri, 8 Jan 2016 20:24:36 +0100
Message-ID: <20160108192436.GB26321@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
 <20160108004238.GD4389@lunn.ch>
 <568F1A1B.1040808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44223 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526AbcAHTYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 14:24:40 -0500
Content-Disposition: inline
In-Reply-To: <568F1A1B.1040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That seems like an elegant way to solve the problem, without adding code
> in the PHY library that does not use the interrupt API, but it also
> seems to me like there are some other potential issues associated with
> doing that:

Hi Florian

I don't want to hijack this thread with DSA stuff. Plus you gave me
some ideas for improvements :-)

Lets come back to this in a couple of weeks once i have the DSA
proposal patches rebased on mdio device, and i've played a bit more.

	 Andrew
