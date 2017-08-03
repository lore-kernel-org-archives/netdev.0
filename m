From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next 5/5] net: dsa: lan9303: refactor
 lan9303_get_ethtool_stats
Date: Thu, 3 Aug 2017 15:30:53 +0200
Message-ID: <20170803133053.GE15018@lunn.ch>
References: <20170803094507.3439-1-privat@egil-hjelmeland.no>
 <20170803094507.3439-6-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170803094507.3439-6-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 11:45:07AM +0200, Egil Hjelmeland wrote:
> In lan9303_get_ethtool_stats: Get rid of 0x400 constant magic
> by using new lan9303_read_switch_reg() inside loop.
> Reduced scope of two variables.
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
