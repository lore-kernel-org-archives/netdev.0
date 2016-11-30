From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/6] net: dsa: mv88e6xxx: add helper to disable
 ports
Date: Thu, 1 Dec 2016 00:20:49 +0100
Message-ID: <20161130232049.GQ21645@lunn.ch>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
 <20161130225930.25510-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130225930.25510-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 05:59:25PM -0500, Vivien Didelot wrote:
> Before resetting a switch, the ports should be set to the Disabled state
> and the transmit queues should be drained.
> 
> Add an helper to explicit that.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
