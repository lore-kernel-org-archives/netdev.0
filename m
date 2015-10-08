From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 4/6] net: dsa: add port_fdb_prepare
Date: Wed, 7 Oct 2015 23:19:28 -0700
Message-ID: <CAE4R7bC=0vWH6Us6_G0_dSg82+acjZBztofKLwsW3JvSe8Steg@mail.gmail.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 7, 2015 at 4:48 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Push the prepare phase for FDB operations down to the DSA drivers, with
> a new port_fdb_prepare function. Currently only mv88e6xxx is affected.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
