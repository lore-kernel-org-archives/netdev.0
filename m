From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: move HWMON support to its own file
Date: Fri, 6 Jan 2017 22:58:33 +0100
Message-ID: <20170106215833.GB10626@lunn.ch>
References: <20170106214200.15633-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170106214200.15633-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 04:42:00PM -0500, Vivien Didelot wrote:
> Isolate the HWMON support in DSA in its own file. Currently only the
> legacy DSA code is concerned.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Seems like a good step towards removing it completely and letting the
PHY do it all.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
