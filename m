From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] remove dead skb_iter* functions
Date: Mon, 1 Nov 2004 15:03:01 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411011502000.5409-100000@thoron.boston.redhat.com>
References: <41868333.7050602@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Christoph Hellwig <hch@lst.de>, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41868333.7050602@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Nov 2004, Patrick McHardy wrote:

> Harald is working on code for pattern-matching inside
> non-linear skbs for conntrack helpers. This code needs
> the skb_iter* functions.

Perhaps put it back when the pattern matching code is submitted upstream.


- James
-- 
James Morris
<jmorris@redhat.com>
