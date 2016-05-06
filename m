From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 13/21] net: dsa: mv88e6xxx: factorize global
 setup
Date: Sat, 7 May 2016 00:29:26 +0200
Message-ID: <20160506222926.GD2073@lunn.ch>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462571843-14397-14-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462571843-14397-14-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  
> -int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
> +static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)

Another _ prefix.

	Andrew
