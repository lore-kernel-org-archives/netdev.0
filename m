From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/8] net: dsa: mv88e6xxx: remove redundant
 assignments
Date: Thu, 9 Jun 2016 04:30:29 +0200
Message-ID: <20160609023029.GH2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2016 at 08:44:50PM -0400, Vivien Didelot wrote:
> The chip->ds and ds->slave_mii_bus assignments are common to both legacy
> and new MDIO probing and are already done in the later setup code.
> 
> Remove the duplicated assignments from the MDIO probing code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
