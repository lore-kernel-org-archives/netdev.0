From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: add STU capability
Date: Tue, 10 May 2016 23:31:26 +0200
Message-ID: <20160510213126.GB24788@lunn.ch>
References: <1462909469-4827-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462909469-4827-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462909469-4827-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2016 at 03:44:29PM -0400, Vivien Didelot wrote:
> Some switch models have a STU (per VLAN port state database). Add a new
> capability flag to switches info, instead of checking their family.
> 
> Also if the 6165 family has an STU, it must have a VTU, so add the
> MV88E6XXX_FLAG_VTU to its family flags.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
