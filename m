From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] switch iph5526_probe to initcalls
Date: Sun, 15 Jun 2003 20:10:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615181030.GA5127@lst.de>
References: <20030615180011.GA4922@lst.de> <20030615.105811.55734399.davem@redhat.com> <20030615180514.GA5006@lst.de> <20030615.110358.10308169.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030615.110358.10308169.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 15, 2003 at 11:03:58AM -0700, David S. Miller wrote:
> At least it's impossible for you to break the tree
> with this change. :)

Take care, I could have smuggled something evil into Space.c..
