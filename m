From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Mon, 2 Aug 2004 13:45:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802114506.GC25951@wotan.suse.de>
References: <20040730060348.GA22854@havoc.gtf.org> <ea86ce220407301229522be64f@mail.gmail.com> <20040730193515.GA11365@havoc.gtf.org> <20040730131004.2be1274d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, tmattox@gmail.com, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040730131004.2be1274d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2004 at 01:10:04PM -0700, David S. Miller wrote:
> On Fri, 30 Jul 2004 15:35:15 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > It is dead code, as-is, in the kernel.  It would require patches to
> > actually work at all.
> > 
> > It is impossible that fastrouting is being actively used, without patches.
> 
> I totally agree.  And people can always resurrect it from the
> repository history or an old tarball if they wish.
> 
> I think it should be killed entirely, and that's what I'm going
> to do.

The s390 people used to use it for local forwarding between partitions.
I don't know if they still do however.

-Andi

> 
