From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/14] net: dsa: mv88e6xxx: rename the port
 vector member
Date: Fri, 10 Mar 2017 01:17:54 +0100
Message-ID: <20170310001754.GB22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42769 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754626AbdCJAR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 19:17:57 -0500
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-10-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 06:33:19PM -0500, Vivien Didelot wrote:
> Not all Marvell switch chips support port trunking, which is embedded in
> the port vector data for ATU operations.
> 
> Rename the portv_trunkid member of the mv88e6xxx_atu_entry structure to
> portvec to be more concise and consistent with the different chips.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
