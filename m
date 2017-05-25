From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/3] net: phy: Create sysfs reciprocal links
 for attached_dev/phydev
Date: Thu, 25 May 2017 18:42:27 +0200
Message-ID: <20170525164227.GB18357@lunn.ch>
References: <20170525162143.18319-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44640 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936076AbdEYQma (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 12:42:30 -0400
Content-Disposition: inline
In-Reply-To: <20170525162143.18319-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 09:21:40AM -0700, Florian Fainelli wrote:
> Hi David, Andrew,
> 
> This patch series addresses a device topology shortcoming where a program
> scanning /sys would not be able to establish a mapping between the network
> device and the PHY device.
> 
> In the process it turned out that no PHY device documentation existed for
> sysfs attributes.
> 
> Thanks!

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
