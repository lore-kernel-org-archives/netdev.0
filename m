From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Wed, 26 Jul 2017 18:44:11 +0200
Message-ID: <20170726164411.GM12049@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41061 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdGZQoN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:44:13 -0400
Content-Disposition: inline
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:01:39PM +0100, Russell King - ARM Linux wrote:
> Hi,
> 
> This patch series introduces generic support for SFP sockets found on
> various Marvell based platforms.  The idea here is to provide common
> SFP socket support which can be re-used by network drivers as
> appropriate, rather than each network driver having to re-implement
> SFP socket support.

Hi Russell

Thanks for posting these patches. I will review them once i catch up
with my backlog.

...

> I currently (but not included in this series) have code to convert
> mvneta to use phylink

Do you have a git branch we can look at to see these changes. It helps
understand the API when you can see both sides of it.

Thanks
	Andrew
