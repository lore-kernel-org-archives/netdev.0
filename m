From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 7/8] net: switchdev: support static FDB addresses
Date: Mon, 10 Aug 2015 08:59:17 -0700
Message-ID: <CAE4R7bAr3uFbv6q4LaE7N+rvv5v=ERX9oy1kSkWT6NidvatcCw@mail.gmail.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1439212193-7673-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2015 at 6:09 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> This patch adds an ndm_state member to the switchdev_obj_fdb structure,
> in order to support static FDB addresses.
>
> Set Rocker ndm_state to NUD_REACHABLE.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
