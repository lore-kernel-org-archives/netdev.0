From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert icmpv6_socket to per-cpu data
Date: Mon, 1 Sep 2003 01:09:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901010945.42f4c01e.davem@redhat.com>
References: <20030831100521.GB18663@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20030831100521.GB18663@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Aug 2003 12:05:21 +0200
Christoph Hellwig <hch@lst.de> wrote:

> per-cpu data works in modules for a while now.  Also bring over a
> comment from the IPv4 version and consolidate the error handling.

Applied, thanks Christoph.
