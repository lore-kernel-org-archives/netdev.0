From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix arcnet module refcounting
Date: Mon, 21 Jul 2003 05:31:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030721053125.2d28d233.davem@redhat.com>
References: <20030713125748.GA24403@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20030713125748.GA24403@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 14:57:48 +0200
Christoph Hellwig <hch@lst.de> wrote:

> struct arnet_local needs a struct module *owner, that also cleans
> up nicely lots of the code.

Applied, thanks Christoph.
