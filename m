From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] net: dsa: mv88e6xxx: port macros
 cosmetics
Date: Tue, 13 Jun 2017 11:23:33 -0400 (EDT)
Message-ID: <20170613.112333.1142029058310682279.davem@davemloft.net>
References: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 12 Jun 2017 12:37:32 -0400

> This patch series brings no functional changes.
> 
> It prefixes all common port registers macros with MV88E6XXX_PORT.
> If registers or some bits differs between switch models, a reference
> model is chosen (e.g. MV88E6390_PORT_MAC_CTL_SPEED_10000.)
> 
> The register names are documented as found in the datasheets.
> 
> Avoid BIT() and shifts defines and prefer a better representation of the
> Marvell switch registers with ordered, hexadecimal, 16-bit values.

Series applied, thanks.
