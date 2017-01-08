From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: select NET_SWITCHDEV
Date: Mon, 9 Jan 2017 00:31:19 +0100
Message-ID: <20170108233119.GB25588@lunn.ch>
References: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 08, 2017 at 06:17:24PM -0500, Vivien Didelot wrote:
> DSA wraps SWITCHDEV, thus select it instead of depending on it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
