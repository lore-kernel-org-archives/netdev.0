From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/stmmac: fix issue of clk_get for Loongson1B.
Date: Mon, 20 Aug 2012 02:52:34 -0700 (PDT)
Message-ID: <20120820.025234.751280633665050946.davem@davemloft.net>
References: <1345284983-12610-1-git-send-email-keguang.zhang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peppe.cavallaro@st.com
To: keguang.zhang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345284983-12610-1-git-send-email-keguang.zhang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelvin Cheung <keguang.zhang@gmail.com>
Date: Sat, 18 Aug 2012 18:16:23 +0800

> When getting clock, give a chance to the CPUs without DT support,
> which use Common Clock Framework, such as Loongson1B.
> 
> Signed-off-by: Kelvin Cheung <keguang.zhang@gmail.com>

Applied, thanks.
