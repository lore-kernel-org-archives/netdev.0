From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] netlink: Add nla_memdup() to wrap kmemdup()
 use on nlattr
Date: Sat, 29 Oct 2016 14:57:54 -0400 (EDT)
Message-ID: <20161029.145754.728917225207338115.davem@davemloft.net>
References: <2d0864c85200f1b42b1ebceee7c2dc60fe29f26a.1477471562.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2d0864c85200f1b42b1ebceee7c2dc60fe29f26a.1477471562.git.tgraf-G/eBtMaohhA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Date: Wed, 26 Oct 2016 10:53:16 +0200

> Wrap several common instances of:
> 	kmemdup(nla_data(attr), nla_len(attr), GFP_KERNEL);
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Applied.
