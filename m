From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert ip6_tunnel to per-cpu data
Date: Sun, 31 Aug 2003 03:15:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030831031556.6d8ee0e8.davem@redhat.com>
References: <20030831100621.GC18663@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20030831100621.GC18663@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Aug 2003 12:06:21 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Code looks like copy & pasted from icmpv6 :)

Hold on this one, we're in the process of killing
the sockets from this code.
