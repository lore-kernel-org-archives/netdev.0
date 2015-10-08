From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: use switchdev obj in port_fdb_del
Date: Wed, 7 Oct 2015 23:20:12 -0700
Message-ID: <CAE4R7bB+XYzLEPZ1UbS7Zz5u41zOiZLNbC7kS8MfBad3R1xnTQ@mail.gmail.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444261711-1829-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-7-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 7, 2015 at 4:48 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> For consistency with the FDB add operation, propagate the
> switchdev_obj_port_fdb structure in the DSA drivers.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
