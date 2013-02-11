From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH] wlcore: remove newly introduced alloc/OOM messages
Date: Mon, 11 Feb 2013 10:07:33 +0200
Message-ID: <1360570053.12803.52.camel@cumari.coelho.fi>
References: <1360569218.12803.50.camel@cumari.coelho.fi>
	 <1360569749-28372-1-git-send-email-coelho@ti.com>
	 <1360570041.2028.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1360570041.2028.18.camel@joe-AO722>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-11 at 00:07 -0800, Joe Perches wrote:
> On Mon, 2013-02-11 at 10:02 +0200, Luciano Coelho wrote:
> > In commit 0d2e7a5c (wireless: Remove unnecessary alloc/OOM messages,
> > alloc cleanups) OOM messages after alloc were removed from the wlcore
> > modules.
> > 
> > Commit afb43e6d (wlcore: remove if_ops from platform_data)
> > reintroduced a couple of those.  This patch removes them.
> 
> You sure?
> 
> The largish patch doesn't match the commit message.

Sorry, I screwed up.  I'll send v2 in a second (should get some more
coffee first ;)

--
Luca.
