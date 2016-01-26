From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 18:53:53 +0100
Message-ID: <20160126175353.GG27473@lunn.ch>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
 <20160126044624.GH3880@lunn.ch>
 <20160126121435.GK22974@ak-desktop.emea.nsn-net.net>
 <20160126133417.GI3880@lunn.ch>
 <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43106 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbcAZRx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 12:53:58 -0500
Content-Disposition: inline
In-Reply-To: <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I hate to bikeshed, but I'm not sure if "generic-mdio" is too...
> generic? Will someone writing a DT be thinking "well, this is a
> generic mdio PHY, I should set it"?  "mdio-device"?
> "generic-nonphy-mdio"? Neither of those seem much better.

How about 'not-a-phy'?

    Andrew
