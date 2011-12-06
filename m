From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] net: Silence seq_scale() unused warning
Date: Tue, 06 Dec 2011 14:00:09 -0500 (EST)
Message-ID: <20111206.140009.2069228986419257738.davem@davemloft.net>
References: <20111206.003157.159978113328078893.davem@davemloft.net>
	<1323194680-32127-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323194680-32127-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Tue,  6 Dec 2011 10:04:40 -0800

> On a CONFIG_NET=y build
> 
> net/core/secure_seq.c:22: warning: 'seq_scale' defined but not
> used
> 
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied, thanks.
