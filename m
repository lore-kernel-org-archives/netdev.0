From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] net Kconfig consolidation
Date: Thu, 25 Sep 2003 20:53:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925205340.7d216b1a.davem@redhat.com>
References: <20030925115717.GA32636@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20030925115717.GA32636@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 25 Sep 2003 13:57:17 +0200
Christoph Hellwig <hch@lst.de> wrote:

> include net/ax25/Kconfig, net/irda/Kconfig and net/bluetooth/Kconfig
> from net/Kconfig like all the other Kconfig files under net/.  This
> makes the per-arch Kconfig files quite a bit smaller and also makes
> sure the option are available on all arches.

Looks great, applied.

Thanks.
