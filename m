From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 06/12] net: dsa: mv88e6xxx: rework Switch
 MAC setter
Date: Mon, 18 Jul 2016 21:39:54 +0200
Message-ID: <20160718193954.GN31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 02:46:22PM -0400, Vivien Didelot wrote:
> Switches such as 88E6185 as 3 Switch MAC registers in Global 1. Newer
> chips such as 88E6352 have freed these registers in favor of an indirect
> access in a Switch MAC/WoL/WoF register in Global 2.
> 
> Explicit this difference with G1 and G2 helpers and flags.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
