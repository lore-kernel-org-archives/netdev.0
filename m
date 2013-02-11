From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH] wlcore: remove newly introduced alloc/OOM messages
Date: Mon, 11 Feb 2013 10:06:43 +0200
Message-ID: <1360570003.12803.51.camel@cumari.coelho.fi>
References: <1360569218.12803.50.camel@cumari.coelho.fi>
	 <1360569749-28372-1-git-send-email-coelho@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <sfr@canb.auug.org.au>, <joe@perches.com>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1360569749-28372-1-git-send-email-coelho@ti.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-11 at 10:02 +0200, Luciano Coelho wrote:
> In commit 0d2e7a5c (wireless: Remove unnecessary alloc/OOM messages,
> alloc cleanups) OOM messages after alloc were removed from the wlcore
> modules.
> 
> Commit afb43e6d (wlcore: remove if_ops from platform_data)
> reintroduced a couple of those.  This patch removes them.
> 
> Signed-off-by: Luciano Coelho <coelho@ti.com>
> ---
> 
> John,
> 
> Can you apply this directly on wireless-next after you process my latest pull-request?
> 
> Thanks!

Ermm... obviously this is completely wrong.  I'll send v2 in a bit.

--
Luca.
