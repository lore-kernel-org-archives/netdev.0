From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 13/14] net: dsa: mv88e6xxx: add port priority
 override op
Date: Fri, 10 Mar 2017 01:39:09 +0100
Message-ID: <20170310003909.GE22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-14-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-14-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 06:33:23PM -0500, Vivien Didelot wrote:
> Add a new operation to disable the DA, SA and VTU priority override.
> 
> Setting such limit is not likely to be used soon, so provide a
> port_disable_pri_override operation directly. This can be changed later
> for port_set_pri_override when we'll need it.
> 
> Also remove the now obsolete mv88e6xxx_6320_family helper.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
