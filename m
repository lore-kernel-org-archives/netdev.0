From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 0/6] net: dsa: mv88e6060: cleanup and fix setup
Date: Tue, 10 Nov 2015 17:14:04 +0100
Message-ID: <20151110161404.GC23891@lunn.ch>
References: <5642126D.9040105@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5642126D.9040105@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 04:51:09PM +0100, Neil Armstrong wrote:
> This patchset introduces some fixes and a registers addressing cleanup for
> the mv88e6060 DSA driver.

Hi Neil

It is normal for netdev to put into the email subject of patches which
tree these patches are for. "net" would be the latest -rcX and is for
fixes only. "net-next" would be for new work aimed at the next merge
window.

So long as Dave does not complain, leave them as they are now. But
please try to follow this for your next patches.

Thanks
       Andrew
