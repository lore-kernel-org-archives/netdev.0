From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/3] net: dsa: push prepare phase in
 port_fdb_add
Date: Thu, 8 Oct 2015 17:48:14 +0200
Message-ID: <20151008154814.GR2186@nanopsycho.orion>
References: <1444318514-32250-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444318514-32250-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444318514-32250-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 08, 2015 at 05:35:13PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>Now that the prepare phase is pushed down to the DSA drivers, propagate
>it to the port_fdb_add function.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
