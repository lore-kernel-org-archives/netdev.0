From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atm: make atmdev_ops const
Date: Wed, 09 Aug 2017 22:44:06 -0700 (PDT)
Message-ID: <20170809.224406.80265328117268100.davem@davemloft.net>
References: <1502271128-6832-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502271128-6832-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed,  9 Aug 2017 15:02:08 +0530

> Make these const as they are only stored in the ops field of a atm_dev
> structure, which is const.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
