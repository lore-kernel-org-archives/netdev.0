From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 03/17] net: dsa: mv88e6xxx: add ATU setup
 helper
Date: Sun, 12 Mar 2017 00:51:30 +0100
Message-ID: <20170311235130.GI15842@lunn.ch>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
 <20170311211303.24560-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170311211303.24560-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 11, 2017 at 04:12:49PM -0500, Vivien Didelot wrote:
> Move the configuration of the default ageing time in a new
> mv88e6xxx_atu_setup function.
> 
> That function will be extended later to contain all ATU related
> configuration bits.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
