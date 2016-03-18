From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ravb: fix result value overwrite
Date: Fri, 18 Mar 2016 19:22:58 -0400 (EDT)
Message-ID: <20160318.192258.806023886924831275.davem@davemloft.net>
References: <1458057136-23253-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1458057136-23253-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Wed, 16 Mar 2016 00:52:16 +0900

> The result value is overwritten by a return value of
> ravb_ptp_interrupt().
> 
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied.
