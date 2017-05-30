From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: remove dsa_port_is_bridged
Date: Mon, 29 May 2017 23:32:18 -0400 (EDT)
Message-ID: <20170529.233218.15598137335473090.davem@davemloft.net>
References: <20170526221242.14875-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526221242.14875-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 26 May 2017 18:12:42 -0400

> The helper is only used once and makes the code more complicated that it
> should. Remove it and reorganize the variables so that it fits on 80
> columns.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
