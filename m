From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: replace open coded
 __netdev_alloc_skb_ip_align() with actual call
Date: Thu, 21 May 2015 18:41:11 -0400 (EDT)
Message-ID: <20150521.184111.1963777803618869451.davem@davemloft.net>
References: <1432103680-5612-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vineet.Gupta1@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432103680-5612-1-git-send-email-vgupta@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Wed, 20 May 2015 12:04:40 +0530

> This also matches with the sibling call netdev_alloc_skb_ip_align() made in
> rx fast path.
> 
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

Applied to net-next, thanks.
