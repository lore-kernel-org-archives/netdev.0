From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ravb: Add SET_RUNTIME_PM_OPS macro
Date: Wed, 01 Jun 2016 16:01:08 -0700 (PDT)
Message-ID: <20160601.160108.856248993077839870.davem@davemloft.net>
References: <1464553543-19091-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1464553543-19091-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Mon, 30 May 2016 05:25:43 +0900

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> Use SET_RUNTIME_PM_OPS macro instead of assigning a member of
> dev_pm_ops directly.
> 
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied.
