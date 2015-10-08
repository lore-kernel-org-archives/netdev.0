From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 3/3] net: dsa: use switchdev obj in
 port_fdb_del
Date: Thu, 8 Oct 2015 17:48:29 +0200
Message-ID: <20151008154829.GS2186@nanopsycho.orion>
References: <1444318514-32250-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444318514-32250-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <1444318514-32250-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Oct 08, 2015 at 05:35:14PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>For consistency with the FDB add operation, propagate the
>switchdev_obj_port_fdb structure in the DSA drivers.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
