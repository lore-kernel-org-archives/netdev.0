From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/6] net: dsa: mv88e6060: cleanup and fix
 setup
Date: Mon, 2 Nov 2015 15:57:03 +0100
Message-ID: <20151102145703.GB7963@lunn.ch>
References: <5637417D.6060503@baylibre.com>
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
In-Reply-To: <5637417D.6060503@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2015 at 11:57:01AM +0100, Neil Armstrong wrote:
> This patchset introduces somes fixes and a registers addressing cleanup for
> the mv88e6060 DSA driver.
> 
> The first patch removes the poll_link as mv88e6xxx.
> The 3 following patchs fixes the setup in regards of the datasheet.
> The 2 last patches introduces a clean header and replaces all magic values.

Hi Neil

Nice patchset. Once you have fixed Sergei's comment, it looks good to
go.

Acked-by: Andrew Lunn <andrew@lunn.ch>

	  Andrew
