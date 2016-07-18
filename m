From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 04/12] net: dsa: mv88e6xxx: extract trunk
 mapping
Date: Mon, 18 Jul 2016 21:36:58 +0200
Message-ID: <20160718193658.GL31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 02:46:20PM -0400, Vivien Didelot wrote:
> The Trunk Mask and Trunk Mapping registers are two Global 2 indirect
> accesses to trunking configuration.
> 
> Add helpers for these tables and simplify the Global 2 setup.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
