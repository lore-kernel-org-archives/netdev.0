From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 18:36:44 +0100
Message-ID: <20160127173644.GJ20194@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-3-git-send-email-andrew@lunn.ch>
 <CAOesGMj6OKYY6thjKX_t-ABogSNrSuQ7rbWPPvhGRtdOTJtXiQ@mail.gmail.com>
 <20160127171109.GE20194@lunn.ch>
 <CAOesGMipfjA9nO8Oe5J_672Xz7nKmR4UAPnoYCBzcZKDiQDFZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44048 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933720AbcA0Rgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:36:45 -0500
Content-Disposition: inline
In-Reply-To: <CAOesGMipfjA9nO8Oe5J_672Xz7nKmR4UAPnoYCBzcZKDiQDFZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Only case I can see the need for a make/model string is if there's a
> need to add model-specific properties since you'd need a compatible
> then (or make those properties shared between all phy bindings).

Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

It adds optional properties to the phy node.

> Anyway, we've never had a huge issue with this on other probable
> busses, so we should be fine with the above. With the clarification
> I'm OK with this change.

Great.

Thanks
	Andrew
