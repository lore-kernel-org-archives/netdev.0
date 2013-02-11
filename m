From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] wlcore: remove newly introduced alloc/OOM messages
Date: Mon, 11 Feb 2013 00:07:21 -0800
Message-ID: <1360570041.2028.18.camel@joe-AO722>
References: <1360569218.12803.50.camel@cumari.coelho.fi>
	 <1360569749-28372-1-git-send-email-coelho@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
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

You sure?

The largish patch doesn't match the commit message.
