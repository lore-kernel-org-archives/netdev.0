From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/3] net: dsa: mv88e6xxx: kill last locked
 reg_read
Date: Thu, 21 Jul 2016 02:44:53 +0200
Message-ID: <20160721004453.GE22834@lunn.ch>
References: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
 <20160720221836.28218-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160720221836.28218-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 20, 2016 at 06:18:36PM -0400, Vivien Didelot wrote:
> Get rid of the last usage of the locked mv88e6xxx_reg_read function with
> a new mv88e6xxx_port_read helper, useful later for chips with different
> port registers base address.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
