From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 03/12] net: dsa: mv88e6xxx: extract device
 mapping
Date: Tue, 19 Jul 2016 04:48:15 +0200
Message-ID: <20160719024815.GB9111@lunn.ch>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719004540.1066-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 08:45:31PM -0400, Vivien Didelot wrote:
> The Device Mapping register is an indirect table access.
> 
> Provide helpers to access this table and explicit the checking of the
> new DSA_RTABLE_NONE routing table value.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
