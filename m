From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: kill circular reference with slave
 priv
Date: Tue, 19 Apr 2016 20:29:07 -0400 (EDT)
Message-ID: <20160419.202907.811707274916296834.davem@davemloft.net>
References: <1461010224-10808-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461010224-10808-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 18 Apr 2016 16:10:24 -0400

> The dsa_slave_priv structure does not need a pointer to its net_device.
> Kill it.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
