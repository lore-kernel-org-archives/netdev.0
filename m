From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next v3 12/14] net: dsa: mv88e6xxx: pass
 compatible info
Date: Sat, 18 Jun 2016 22:28:44 +0200
Message-ID: <20160618202844.GG7172@lunn.ch>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
 <20160618000736.5598-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160618000736.5598-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 08:07:34PM -0400, Vivien Didelot wrote:
> After allocating the chip structure, pass it a compatible info pointer.
> 
> The compatible info structure will be used later to describe how to
> access the switch registers and where to read the switch ID.
> 
> For the standard MDIO probe, get it from the device node data. For the
> legacy DSA driver probing, pass it the 88E6085 info.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
