From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/7] net: dsa: mv88e6xxx: use bridge state
 values
Date: Fri, 9 Jun 2017 15:17:10 +0200
Message-ID: <20170609131710.GB20756@lunn.ch>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
 <20170608223414.594-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608223414.594-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 06:34:10PM -0400, Vivien Didelot wrote:
> Reuse the BR_STATE_* values to abstract a port STP state value.
> 
> This provides shorter names and better control over the DSA switch
> operation call.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
