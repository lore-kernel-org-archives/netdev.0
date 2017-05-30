From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/7] net: dsa: remove unused arguments of tagger
 rcv
Date: Tue, 30 May 2017 17:13:52 +0200
Message-ID: <20170530151352.GF22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:27AM -0400, Vivien Didelot wrote:
> The struct dsa_device_ops defines the rcv function with 2 unused
> arguments struct packet_type *pt, and struct net_device *orig_dev.
> 
> This patch removes them from the definition and implementations.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
