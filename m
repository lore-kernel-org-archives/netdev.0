From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next] phy: increase size of MII_BUS_ID_SIZE and
 bus_id
Date: Thu, 19 Jan 2017 17:40:13 +0100
Message-ID: <20170119164013.GH21805@lunn.ch>
References: <1484841904-19313-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se,
        Magnus =?iso-8859-1?Q?=D6berg?= <magnus.oberg@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38225 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753865AbdASQlD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 11:41:03 -0500
Content-Disposition: inline
In-Reply-To: <1484841904-19313-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 05:05:04PM +0100, Volodymyr Bendiuga wrote:
> Some bus names are pretty long and do not fit into
> 17 chars. Increase therefore MII_BUS_ID_SIZE and
> phy_fixup.bus_id to larger number. Now mii_bus.id
> can host larger name.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
