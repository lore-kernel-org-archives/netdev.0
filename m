From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/9] net: dsa: mv88e6xxx: factorize switch
 info
Date: Sun, 17 Apr 2016 18:54:32 -0400 (EDT)
Message-ID: <20160417.185432.135704308188005510.davem@davemloft.net>
References: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun, 17 Apr 2016 13:23:54 -0400

> This patchset factorizes the mv88e6xxx code by sharing a new extendable
> info structure to store static data such as switch family, product
> number, number of ports, number of databases and the name.
 ...

Series applied, thanks Vivien.
