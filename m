From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next v3 06/14] net: dsa: mv88e6xxx: use gpio get
 optional variant
Date: Sat, 18 Jun 2016 22:17:39 +0200
Message-ID: <20160618201739.GA7172@lunn.ch>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
 <20160618000736.5598-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160618000736.5598-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 08:07:28PM -0400, Vivien Didelot wrote:
> Use the optional variant to get the reset GPIO line, instead of checking
> for the -ENOENT error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
