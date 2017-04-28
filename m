From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 14/18] net: dsa: mv88e6xxx: add VTU Load/Purge
 operation
Date: Fri, 28 Apr 2017 04:14:47 +0200
Message-ID: <20170428021447.GD13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-15-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44000 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1423472AbdD1COv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 22:14:51 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-15-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:32AM -0400, Vivien Didelot wrote:
> Add a new vtu_loadpurge operation to the chip info structure to differ
> the various implementations of the VTU accesses.
> 
> Now that the STU handling is abstracted behind VTU operations, kill the
> obsolete MV88E6XXX_FLAG_STU flag.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
