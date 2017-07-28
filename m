From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: dsa: lan9303: Fix MDIO issues.
Date: Fri, 28 Jul 2017 17:24:55 +0200
Message-ID: <20170728152455.GI2132@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 05:11:53PM +0200, Egil Hjelmeland wrote:
> This series fix the MDIO interface for the lan9303 DSA driver.
> Bugs found after testing on actual HW.
> 
> This series is extracted from the first patch of my first large
> series.

Hi Egil

Thanks for breaking the patch up. It was much easier to understand and
review.

	Andrew
