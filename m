From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 16:32:29 +0200
Message-ID: <20160714143229.GG6667@lunn.ch>
References: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
 <20160714133706.GF6667@lunn.ch>
 <1468504316.2260.35.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Philipp Zabel <p.zabel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42443 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbcGNOcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 10:32:36 -0400
Content-Disposition: inline
In-Reply-To: <1468504316.2260.35.camel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Hi Philipp
> > 
> > Could you use a more descriptive property name? "micrel,enable-fiber"?
> 
> "micrel,fiber-mode" ?

Sure,

Thanks,
	Andrew
