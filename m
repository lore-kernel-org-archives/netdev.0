From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: dsa: mv88e6xxx: rename single-chip
 support
Date: Sat, 25 Jun 2016 11:49:39 -0400 (EDT)
Message-ID: <20160625.114939.1800865976096043323.davem@davemloft.net>
References: <20160621162820.11603-1-vivien.didelot@savoirfairelinux.com>
	<20160621162820.11603-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160621162820.11603-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 21 Jun 2016 12:28:20 -0400

> With the upcoming support for cross-chip operations, it will be hard to
> distinguish portions of code supporting a single-chip or a switch fabric
> of interconnected chips.
> 
> Make the code clearer now, by renaming the mv88e6xxx_priv_state chip
> structure to mv88e6xxx_chip. This patch brings no functional changes.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
