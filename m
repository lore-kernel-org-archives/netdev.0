From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: dsa: mv88e6xxx: improve ATU move
 operations
Date: Tue, 15 Sep 2015 12:04:38 -0700 (PDT)
Message-ID: <20150915.120438.882502363427697063.davem@davemloft.net>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  4 Sep 2015 14:34:09 -0400

> This patchset completes the set of available Address Translation Unit
> operations.
> 
> These Marvell switches have 4 operations to flush or (re)move, all or
> only non-static MAC addresses, from the entire set of databases or from
> just a particular one.
> 
> The first 3 patches introduce a generic _mv88e6xxx_atu_flush_move
> function. The 4 remaining patches update a few FID operations in the
> driver on setup, when a port join or leave a VLAN, or change state.
> 
> This is a step forward improving the hardware bridging support in DSA
> and 88E6352-compatible switches.

Series applied, thanks.
