From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] ipv6: drop unneeded goto
Date: Sat, 30 May 2015 23:49:03 -0700 (PDT)
Message-ID: <20150530.234903.1472680085573416428.davem@davemloft.net>
References: <1432846944-7122-1-git-send-email-Julia.Lawall@lip6.fr>
	<1432846944-7122-3-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432846944-7122-3-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Thu, 28 May 2015 23:02:17 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Delete jump to a label on the next line, when that label is not
> used elsewhere.
> 
> A simplified version of the semantic patch that makes this change is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Also remove the unnecessary ret variable.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks Julia.
