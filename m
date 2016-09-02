From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: remove ds_to_priv
Date: Thu, 01 Sep 2016 22:51:48 -0700 (PDT)
Message-ID: <20160901.225148.342353095084806051.davem@davemloft.net>
References: <20160831220613.8727-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831220613.8727-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 31 Aug 2016 18:06:13 -0400

> Access the priv member of the dsa_switch structure directly, instead of
> having an unnecessary helper.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
