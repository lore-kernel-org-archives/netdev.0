From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: add port enable and disable
 helpers
Date: Fri, 22 Sep 2017 18:35:54 +0200
Message-ID: <20170922163554.GC3470@lunn.ch>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170922161753.19563-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 12:17:53PM -0400, Vivien Didelot wrote:
> Provide dsa_port_enable and dsa_port_disable helpers to respectively
> enable and disable a switch port. This makes the dsa_port_set_state_now
> helper static.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
