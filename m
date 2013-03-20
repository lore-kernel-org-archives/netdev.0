From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: add missing error path release_sock call
Date: Wed, 20 Mar 2013 12:23:36 -0400 (EDT)
Message-ID: <20130320.122336.2213528931007672779.davem@davemloft.net>
References: <20130320151924.GA4955@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, samuel@sortiz.org,
	netdev@vger.kernel.org, spender@grsecurity.net
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130320151924.GA4955@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Mar 2013 08:19:24 -0700

> This makes sure that release_sock is called for all error conditions in
> irda_getsockopt.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Reported-by: Brad Spengler <spender@grsecurity.net>

Applied, thanks.
