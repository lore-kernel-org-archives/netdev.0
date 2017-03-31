From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 4/9] net: dsa: mv88e6xxx: allocate the number
 of ports
Date: Fri, 31 Mar 2017 18:27:40 +0200
Message-ID: <20170331162740.GF12814@lunn.ch>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
 <20170330213715.9666-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170330213715.9666-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 05:37:10PM -0400, Vivien Didelot wrote:
> The current code allocates DSA_MAX_PORTS ports for a Marvell dsa_switch
> structure. Provide the exact number of ports so the corresponding
> ds->num_ports is accurate.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
