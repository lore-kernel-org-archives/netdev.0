From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Tue, 11 Apr 2017 16:34:57 +0200
Message-ID: <20170411143457.GJ27307@lunn.ch>
References: <20170411072259.15356-1-jbe@pengutronix.de>
 <20170411072259.15356-3-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54988 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751047AbdDKOe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 10:34:58 -0400
Content-Disposition: inline
In-Reply-To: <20170411072259.15356-3-jbe@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 09:22:57AM +0200, Juergen Borleis wrote:
> The SMSC/Microchip LAN9303 is an ethernet switch device with one CPU port
> and two external ethernet ports with built-in phys.
> 
> This driver uses the DSA framework, but is currently only capable of
> separating the two external ports. There is no offload support yet.
> 
> Signed-off-by: Juergen Borleis <jbe@pengutronix.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
