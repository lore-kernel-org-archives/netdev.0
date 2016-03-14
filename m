From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: refine netdev event notifier
Date: Mon, 14 Mar 2016 10:10:04 +0200
Message-ID: <20160314081004.GB3060@colbert.mtl.com>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457900494-10266-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, "Jiri Pirko" <jiri@resnulli.us>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457900494-10266-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Mar 13, 2016 at 10:21:34PM IST, vivien.didelot@savoirfairelinux.com wrote:
>Rework the netdev event handler, similar to what the Mellanox Spectrum
>driver does, to easily welcome more events later (for example
>NETDEV_PRECHANGEUPPER) and use netdev helpers (such as
>netif_is_bridge_master).
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Ido Schimmel <idosch@mellanox.com>
