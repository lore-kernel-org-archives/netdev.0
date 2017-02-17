From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 6/6] net: dsa: mv88e6xxx: add support for
 6390 VTU
Date: Fri, 17 Feb 2017 22:53:36 +0100
Message-ID: <20170217215336.GL6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44103 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934998AbdBQVzS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:55:18 -0500
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-7-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 10:05:31AM -0500, Vivien Didelot wrote:
> The 6390 family of chips use only 2 of the 3 VTU Data registers to pack
> the MemberTag and PortState VLAN data. This means that they must be
> written or read before or after each VTU/STU operations.
> 
> Implement this variant to add support for VTU with such chips.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
