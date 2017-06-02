From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/5] net: dsa: mv88e6xxx: move registers macros
Date: Fri, 2 Jun 2017 23:16:47 +0200
Message-ID: <20170602211647.GA28084@lunn.ch>
References: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 05:06:14PM -0400, Vivien Didelot wrote:
> This patchset brings no functional changes.
> 
> It is the first step of a cleanup renaming the chip header file and
> moving the Register definitions _as is_ in their proper header files.
> 
> A following patchset will prefix them with the appropriate model
> (MV88E6XXX_ or e.g. MV88E6390_) to respect an implicit namespace and
> easily identify model subtleties in registers layout, as correctly done
> in the newly added serdes.h header.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
