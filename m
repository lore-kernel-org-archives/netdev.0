From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/7] net: dsa: mv88e6xxx: add number of ports
 to info
Date: Sat, 16 Apr 2016 01:59:42 +0200
Message-ID: <20160415235942.GE32136@lunn.ch>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460762488-2633-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460762488-2633-6-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 07:21:26PM -0400, Vivien Didelot wrote:
> Drop the ps->num_ports variable for a new member of the info structure.
> This removes the need to assign it at setup time.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
