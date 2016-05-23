From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Mon, 23 May 2016 13:53:16 +0200
Message-ID: <20160523115316.GA17916@lunn.ch>
References: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
 <20160523024217.GB20405@lunn.ch>
 <9231D502B07C5E4A8B32D5115C9F19991E917475@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"alexander.stein@systec-electronic.com"
	<alexander.stein@systec-electronic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"john@phrozen.org" <john@phrozen.org>,
	"openwrt@kresin.me" <openwrt@kresin.me>
To: "Mehrtens, Hauke" <hauke.mehrtens@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47858 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbcEWLxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2016 07:53:23 -0400
Content-Disposition: inline
In-Reply-To: <9231D502B07C5E4A8B32D5115C9F19991E917475@IRSMSX101.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I doubt the device tree maintainers will accept this. You don't normally put
> > register values in device tree.
> 
> Me too ;-)
> 

> I will look into this:
> http://lists.openwall.net/netdev/2016/03/23/61 and also try to make
> the device tree interface more generic.

Please take more notice of my emails than what was submitted.

> Should I first send a patch without the led configuration so this led stuff is a separate topic?

Yes, you can do that. If you go the direction i suggests, that it a
big piece of work, and does not need to hold up the rest of the
driver.

	Andrew
