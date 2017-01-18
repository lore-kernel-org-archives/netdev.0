From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: dsa: store CPU switch structure in
 the tree
Date: Wed, 18 Jan 2017 16:50:05 -0500 (EST)
Message-ID: <20170118.165005.1597826635315706517.davem@davemloft.net>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 17 Jan 2017 20:41:38 -0500

> Store a dsa_switch pointer to the CPU switch in the tree instead of only
> its index. This avoids the need to initialize it to -1.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
