From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Wed, 26 Jul 2017 19:07:29 +0100
Message-ID: <20170726180729.GP31807@n2100.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <20170726164411.GM12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:42298 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdGZSHg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:07:36 -0400
Content-Disposition: inline
In-Reply-To: <20170726164411.GM12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 06:44:11PM +0200, Andrew Lunn wrote:
> Do you have a git branch we can look at to see these changes. It helps
> understand the API when you can see both sides of it.

git://git.armlinux.org.uk/~rmk/linux-arm.git phy

or head to the cgit at:

git.armlinux.org.uk/cgit/linux-arm.git/log/?h=phy

Not only does that include the mvneta changes, but also the changes to
the 88x3310 driver (although incomplete, but functional.)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
