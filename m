From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Convert remaining uses of
 pr_warning to pr_warn
Date: Tue, 09 Sep 2014 20:37:32 -0700 (PDT)
Message-ID: <20140909.203732.1451216065011764152.davem@davemloft.net>
References: <1410319664.24028.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410319664.24028.6.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 09 Sep 2014 20:27:44 -0700

> Use the much more common pr_warn instead of pr_warning.
> 
> Other miscellanea:
> 
> o Typo fixes submiting/submitting
> o Coalesce formats
> o Realign arguments
> o Add missing terminating '\n' to formats
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Most of these are old drivers so I'm not cc'ing everyone.
> Let me know if you want these separated or simply dropped.
> 
> This does add a long line for a coalesced variable.
> I think it reads better whole than in pieces.

Applied, thanks.
