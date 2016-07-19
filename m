From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 11/12] net: dsa: mv88e6xxx: add G1 helper for
 ageing time
Date: Tue, 19 Jul 2016 16:47:37 +0200
Message-ID: <20160719144737.GD31103@lunn.ch>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
 <20160719144518.GC31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719144518.GC31103@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi Vivien
> 
> This is doing a read/modify/write, so should really hold the mutex.

Upps. The mutex is held. Sorry for the noise.

      Andrew
