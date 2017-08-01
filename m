From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 11/11] net: dsa: rename switch EEE ops
Date: Tue, 1 Aug 2017 23:08:14 +0200
Message-ID: <20170801210814.GS23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801203241.22294-12-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:41PM -0400, Vivien Didelot wrote:
> To avoid confusion with the PHY EEE settings, rename the .set_eee and
> .get_eee ops to respectively .set_mac_eee and .get_mac_eee.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
