From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 12/18] net: dsa: mv88e6xxx: load STU entry with
 VTU entry
Date: Fri, 28 Apr 2017 04:07:44 +0200
Message-ID: <20170428020744.GB13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 11:53:30AM -0400, Vivien Didelot wrote:
> Now that the code writes both VTU and STU data when loading a VTU entry,
> load the corresponding STU entry at the same time.
> 
> This allows us to get rid of the STU management in the
> _mv88e6xxx_vtu_new helper and thus remove the separate implementations
> of STU Load/Purge and STU GetNext, as well as the unused family checks.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
