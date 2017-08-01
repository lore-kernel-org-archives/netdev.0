From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 10/11] net: dsa: mv88e6xxx: remove EEE support
Date: Tue, 1 Aug 2017 23:07:27 +0200
Message-ID: <20170801210727.GR23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801203241.22294-11-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:40PM -0400, Vivien Didelot wrote:
> The PHY's EEE settings are already accessed by the DSA layer through the
> Marvell PHY driver and there is nothing to be done for switch's MACs.
> 
> Remove all EEE support from the mv88e6xxx driver and simply return 0
> from the EEE ops.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
