From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 16/18] net: dsa: mv88e6xxx: simplify VTU entry
 getter
Date: Fri, 28 Apr 2017 04:19:49 +0200
Message-ID: <20170428021949.GF13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-17-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-17-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 11:53:34AM -0400, Vivien Didelot wrote:
> Make the code which fetches or initializes a new VTU entry more concise.
> This allows us the get rid of the old underscore prefix naming.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
