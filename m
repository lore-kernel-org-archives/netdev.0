From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: disable SA learning for DSA
 and CPU ports
Date: Tue, 03 Nov 2015 11:35:03 -0500 (EST)
Message-ID: <20151103.113503.1422547127820558052.davem@davemloft.net>
References: <1446565956-14893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446565956-14893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue,  3 Nov 2015 10:52:36 -0500

> From: Andrew Lunn <andrew@lunn.ch>
> 
> Frames with DSA headers passing to/from the CPU were taking place in the
> MAC learning on these ports, resulting in incorrect ATU entries. Disable
> learning on these ports.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
