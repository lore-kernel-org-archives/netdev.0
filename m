From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 1/1]  net: phy: Add edge-rate, mac-if, read, write
 func to Microsemi PHYs.
Date: Mon, 22 Aug 2016 15:39:53 +0200
Message-ID: <20160822133953.GD14068@lunn.ch>
References: <20160808134325.GA4376@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40463 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755285AbcHVNj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 09:39:56 -0400
Content-Disposition: inline
In-Reply-To: <20160808134325.GA4376@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2016 at 07:13:28PM +0530, Nagaraju Lakkaraju wrote:
> crosemi PHYsBcc: 
> Subject: [PATCH v1 1/1]  net: phy: Add edge-rate, mac-if, read, write func to
> Reply-To: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com> 
> 
> Hello,
> 
> As part of 2nd patch, Add Edge rate control, MAC Interface, Read and write driver functions add for Microsemi PHYs.

Please add these different features as separate patches.  You should
be aiming for a number of small patches, each of which are obviously
correct, not one big patch containing multiple things which are hard
to review.

       Andrew
