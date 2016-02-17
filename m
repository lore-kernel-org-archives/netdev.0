From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next] net: bridge: log port STP state on change
Date: Wed, 17 Feb 2016 12:14:27 +0200
Message-ID: <20160217101427.GA388@colbert.mtl.com>
References: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455635391-25311-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Feb 16, 2016 at 05:09:51PM IST, vivien.didelot@savoirfairelinux.com wrote:
>Remove the shared br_log_state function and print the info directly in
>br_set_state, where the net_bridge_port state is actually changed.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>---

Acked-by: Ido Schimmel <idosch@mellanox.com>

Thanks Vivien.
