From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Sun, 6 Aug 2017 20:26:22 +0200
Message-ID: <20170806182622.GA31844@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53330 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751324AbdHFS0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 6 Aug 2017 14:26:25 -0400
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

Please could you repost with all the Reviewed-By added and RFC
removed. The code should get merged then.

Thanks
	Andrew
