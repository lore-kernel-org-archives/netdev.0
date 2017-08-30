From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcm63xx_enet: make bcm_enetsw_ethtool_ops const
Date: Wed, 30 Aug 2017 15:20:35 -0700 (PDT)
Message-ID: <20170830.152035.99832287168105841.davem@davemloft.net>
References: <1504085108-23495-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504085108-23495-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed, 30 Aug 2017 14:55:08 +0530

> Make this const as it is never modified.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied to net-next.
