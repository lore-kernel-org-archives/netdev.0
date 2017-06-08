From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/7] net: dsa: mv88e6xxx: add egress mode
 enumeration
Date: Thu, 8 Jun 2017 21:38:02 +0200
Message-ID: <20170608193802.GH20216@lunn.ch>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
 <20170608190445.24443-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608190445.24443-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:04:40PM -0400, Vivien Didelot wrote:
> As for the frame mode, add a mv88e6xxx_egress_mode enumeration instead
> of a 16-bit register mask.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
