From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 10:12:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716141206.GB5628@gtf.org>
References: <20030716092354.GC24077@suse.de> <20030716054255.1922d299.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mads Martin J?rgensen <mmj@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030716054255.1922d299.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2003 at 05:42:55AM -0700, David S. Miller wrote:
> This whole anti-kernel-headers-in-userspace thing is a
> total shamans dance and not founded in reality.

There ARE definitions that differ between kernel and userspace.

Thinking they are the same is not founded in reality.

And thinking that all of userspace is instantly recompiled against
against the latest kernel headers isn't founded in reality, either.

	Jeff
