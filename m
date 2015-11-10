From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 2/6] net: dsa: mv88e6060: use the correct InitReady bit
Date: Tue, 10 Nov 2015 11:03:49 -0500
Message-ID: <20151110160349.GB28387@ketchup.mtl.sfl>
References: <56421277.1030601@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56421277.1030601@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov. Tuesday 10 (46) 04:51 PM, Neil Armstrong wrote:
> According to the mv88e6060 datasheet, the InitReady bit position
> is 11 and the polarity is inverted.
> Use the bit correctly to detect the end of initialization.
> 
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Acked-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
