From: "David S. Miller" <davem@redhat.com>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 07:14:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716071426.11449bed.davem@redhat.com>
References: <20030716092354.GC24077@suse.de>
	<20030716054255.1922d299.davem@redhat.com>
	<20030716141206.GB5628@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mmj@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030716141206.GB5628@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 10:12:06 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> There ARE definitions that differ between kernel and userspace.

Sure, but none of the one's were talking about here.

> Thinking they are the same is not founded in reality.

I'm not.

> And thinking that all of userspace is instantly recompiled against
> against the latest kernel headers isn't founded in reality, either.

GLIBC is munging netlink messages on the way out via sendmsg()?
That'd be news to me. :-)
