From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 07/11] net: dsa: mv88e6xxx: add port link
 setter
Date: Fri, 4 Nov 2016 10:30:21 +0100
Message-ID: <20161104093021.GD13959@lunn.ch>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
 <20161104022336.14273-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161104022336.14273-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 04, 2016 at 03:23:32AM +0100, Vivien Didelot wrote:
> Most of the chips will have a port register control bits to force the
> port's link up, down, or let normal link detection occurs.
> 
> Implement such operation to use it later when setting duplex, etc.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Hi Vivien

Thanks for the change. Interesting choice of values.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
