From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] enabling netdev boot options (2.6.0-t9)
Date: Sat, 8 Nov 2003 22:06:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108220621.11d39feb.akpm@osdl.org>
References: <20031108160441.3a0a5505.rddunlap@osdl.org>
	<20031108204406.5dbbdc87.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, saw@saw.sw.com.sg
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031108204406.5dbbdc87.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Randy.Dunlap" <rddunlap@osdl.org> wrote:
>
> +int dev_alloc_name_lock(struct net_device *dev, const char *name)

You'll need to export this guy to modules.
