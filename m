From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: make dsa_switch_ops const
Date: Wed, 09 Aug 2017 22:43:04 -0700 (PDT)
Message-ID: <20170809.224304.2036941071364761416.davem@davemloft.net>
References: <1502255055-24751-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502255055-24751-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed,  9 Aug 2017 10:34:15 +0530

> Make these structures const as they are only stored in the ops field of
> a dsa_switch structure, which is const.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied, thank you.
