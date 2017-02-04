From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/6] net: dsa: introduce bridge notifier
Date: Sat, 4 Feb 2017 19:30:44 +0100
Message-ID: <20170204183044.GF8364@lunn.ch>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
 <20170203182021.14246-7-vivien.didelot@savoirfairelinux.com>
 <20170204175517.GC8364@lunn.ch>
 <87tw89yfqf.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87tw89yfqf.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > What we don't want is a window of time during the fabric setup as a
> > whole is inconsistent, and frames a leaking out ports they should not.
> 
> There is no such window.

Hi Vivien

Great, that is what i wanted to hear.

Thanks
	Andrew
