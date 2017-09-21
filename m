From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: add port fdb dump
Date: Thu, 21 Sep 2017 15:24:22 -0700 (PDT)
Message-ID: <20170921.152422.861638020110977067.davem@davemloft.net>
References: <20170920233214.6936-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920233214.6936-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 20 Sep 2017 19:32:14 -0400

> Dumping a DSA port's FDB entries is not specific to a DSA slave, so add
> a dsa_port_fdb_dump function, similarly to dsa_port_fdb_add and
> dsa_port_fdb_del.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
