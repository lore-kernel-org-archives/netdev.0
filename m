From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (9/9) bridge - fdb cache alloc
Date: Fri, 16 Apr 2004 14:23:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416142344.37eb3d6f.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413153453.4765b26a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413153453.4765b26a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:34:53 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Since forwarding database gets a lot of memory alloc/free on a busy
> bridge, use kmem_cache_alloc to provide cache and better stats.

Applied.
