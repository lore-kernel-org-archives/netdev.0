From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] net: dsa: rename port_*_bridge routines
Date: Sun, 13 Mar 2016 21:56:35 +0100
Message-ID: <20160313205635.GB2274@nanopsycho.orion>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457900494-10266-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457900494-10266-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Mar 13, 2016 at 09:21:32PM CET, vivien.didelot@savoirfairelinux.com wrote:
>Rename DSA port_join_bridge and port_leave_bridge routines to
>respectively port_bridge_join and port_bridge_leave in order to respect
>an implicit Port::Bridge namespace.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
