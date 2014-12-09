From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sh_eth: Remove redundant alignment adjustment
Date: Tue, 09 Dec 2014 18:05:57 -0500 (EST)
Message-ID: <20141209.180557.368241481301484599.davem@davemloft.net>
References: <1418035581-3805-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1418035581-3805-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Mon,  8 Dec 2014 19:46:21 +0900

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> 
> PTR_ALIGN macro after skb_reserve is redundant, because skb_reserve
> function adjusts the alignment of skb->data.
> 
> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied.
