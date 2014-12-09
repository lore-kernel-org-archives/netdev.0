From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sh_eth: Optimization for RX excess judgement
Date: Tue, 09 Dec 2014 18:06:22 -0500 (EST)
Message-ID: <20141209.180622.1299267904682284783.davem@davemloft.net>
References: <1418127822-16904-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1418127822-16904-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Tue,  9 Dec 2014 21:23:42 +0900

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> 
> Both of 'boguscnt' and 'quota' have nearly meaning as the condition of
> the reception loop.
> In order to cut down redundant processing, this patch changes excess
> judgement.
> 
> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied.
