From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 05:46:24 +0100
Message-ID: <20160126044624.GH3880@lunn.ch>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42640 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412AbcAZEq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 23:46:27 -0500
Content-Disposition: inline
In-Reply-To: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 05:45:21PM +0200, Aaro Koskinen wrote:
> Hi,
> 
> I get the below crash on OCTEON (with octeon_mgmt interface, genphy)
> always during systemd boot.

Hi Aaro

I think i know what is going on now.

What does your phy look like in DT?

Thanks
	Andrew
