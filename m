From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/8] net: dsa: prefix Global macros
Date: Thu, 15 Jun 2017 19:03:11 +0200
Message-ID: <20170615170311.GF3786@lunn.ch>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2017 at 12:13:58PM -0400, Vivien Didelot wrote:
> This patch series is the 2/3 step of the register definitions cleanup.
> It brings no functional changes.
> 
> It prefixes and documents all Global (1) registers with MV88E6XXX_G1_
> (or a specific model like MV88E6352_G1_STS_PPU_STATE), and prefers a
> 16-bit hexadecimal representation of the Marvell registers layout.
> 
> The next and last patchset will prefix the Global 2 registers.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
