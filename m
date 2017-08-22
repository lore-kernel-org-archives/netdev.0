From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-gpio: make mdiobb_ops const
Date: Tue, 22 Aug 2017 14:23:29 -0700 (PDT)
Message-ID: <20170822.142329.2014748731132356164.davem@davemloft.net>
References: <1503389609-17490-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503389609-17490-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Tue, 22 Aug 2017 13:43:29 +0530

> Make this const as it is only stored in a const field of a
> mdiobb_ctrl structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
