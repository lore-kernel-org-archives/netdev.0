From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bugme-new] [Bug 1371] New: kernel fails to compile with ipv6
 error
Date: Sun, 19 Oct 2003 00:03:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031019000341.5769859a.davem@redhat.com>
References: <200310182118.h9ILIBMX001067@fire-1.osdl.org>
	<20031018160855.26fea7b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: simon@swat.me.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031018160855.26fea7b8.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 16:08:55 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Odd.  Please send your .config.

Known issue, see the patch from Herbert Xu posted yesterday
to linux-net (subject: "Re: [PATCH][2.6] fix compilation w/o
CONFIG_XFRM").

It will cure this and other such issues.
