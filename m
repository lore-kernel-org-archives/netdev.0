From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: mv88e6xxx: remove 88E6391 ops
Date: Tue, 28 Mar 2017 21:00:21 +0200
Message-ID: <20170328190021.GD2268@lunn.ch>
References: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
 <20170328175035.13897-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170328175035.13897-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 01:50:35PM -0400, Vivien Didelot wrote:
> We don't support 88E6391 anywhere in the code, so remove the unused
> mv88e6391_ops structure.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
