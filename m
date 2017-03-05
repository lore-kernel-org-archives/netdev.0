From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Tighten some of the net/phy SoC dependencies
Date: Sun, 5 Mar 2017 16:09:12 +0100
Message-ID: <20170305150912.GB11251@lunn.ch>
References: <20170305121434.22674-1-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Peter Robinson <pbrobinson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60329 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752425AbdCEPJh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 10:09:37 -0500
Content-Disposition: inline
In-Reply-To: <20170305121434.22674-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 05, 2017 at 12:14:32PM +0000, Peter Robinson wrote:
> A pair of small Kconfig patches to tightend some of the PHY MDIO 
> dependencies one the SoCs, fairly self explanatory.

Hi Peter

Please use git format-patch --cover to generate the cover note for a
patch set.

[PATCH 1/2] net: phy: Add dependencies for Cavium SoCs
[PATCH 2/2/2] net:phy:hisi: Depend on the appropraite SoC

It would be nice to have consistent spacing in the subject line
prefixes. And the correct spelling of appropriate.

	  Thanks
		Andrew
