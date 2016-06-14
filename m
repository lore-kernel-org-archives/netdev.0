From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 05/12] net: dsa: mv88e6xxx: add switch
 register helpers
Date: Tue, 14 Jun 2016 23:17:22 +0200
Message-ID: <20160614211722.GE12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 02:31:46PM -0400, Vivien Didelot wrote:
> The mixed assignments, allocations and registrations in the probe code
> make it hard to follow the logic and figure out what is DSA or chip
> specific.
> 
> Extract the struct dsa_switch related code in a simple
> mv88e6xxx_register_switch helper function.
> 
> For symmetry in the code, add a mv88e6xxx_unregister_switch function.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
