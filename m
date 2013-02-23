From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: remove depends on CONFIG_EXPERIMENTAL
Date: Sat, 23 Feb 2013 13:54:39 -0500 (EST)
Message-ID: <20130223.135439.1188316565117960228.davem@davemloft.net>
References: <20130223072538.GA4770@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130223072538.GA4770@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 22 Feb 2013 23:25:38 -0800

> The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
> while now and is almost always enabled by default. As agreed during the
> Linux kernel summit, remove it from any "depends on" lines in Kconfigs.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
