From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NET]: Lockless loopback patch (version 2).
Date: Mon, 21 Jun 2004 09:39:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621093918.61b43aad.davem@redhat.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
	<20040621035702.6114bdbe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040621035702.6114bdbe.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Jun 2004 03:57:02 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Still, I don't see why we need to use alloc_percpu() - why not
> statically allocate it?
> 
> This compiles, but does need runtime testing.

Looks good to me, applied.
