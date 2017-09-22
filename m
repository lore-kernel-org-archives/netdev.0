From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/4] net: dsa: remove phy arg from port
 enable/disable
Date: Fri, 22 Sep 2017 21:11:05 +0200
Message-ID: <20170922191105.GF3470@lunn.ch>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-3-vivien.didelot@savoirfairelinux.com>
 <f8d74c3c-bd7f-8a84-2d57-c37250ff25f8@gmail.com>
 <87377eob5t.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <6d7799bb-2b33-0696-1805-63cea5e52667@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6d7799bb-2b33-0696-1805-63cea5e52667@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Historical reasons mostly. Considering the complexity of
> dsa_slave_phy_setup(), I would certainly be extremely careful in
> changing any of this, the potential for breakage is pretty big.

Yes, i took a look at this, wondering how to convert to phylink. I
went away and got a stiff drink :-)

     Andrew
