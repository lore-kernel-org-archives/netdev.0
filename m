From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: make irq_chip const
Date: Sun, 20 Aug 2017 20:03:33 -0700 (PDT)
Message-ID: <20170820.200333.261395041365539967.davem@davemloft.net>
References: <1503140152-7719-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503140152-7719-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Sat, 19 Aug 2017 16:25:52 +0530

> Make this const as it is only used in a copy operation.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied to net-next, thanks.
