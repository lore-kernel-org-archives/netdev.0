From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 13:10:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730131004.2be1274d.davem@redhat.com>
References: <20040730060348.GA22854@havoc.gtf.org>
	<ea86ce220407301229522be64f@mail.gmail.com>
	<20040730193515.GA11365@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tmattox@gmail.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040730193515.GA11365@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004 15:35:15 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> It is dead code, as-is, in the kernel.  It would require patches to
> actually work at all.
> 
> It is impossible that fastrouting is being actively used, without patches.

I totally agree.  And people can always resurrect it from the
repository history or an old tarball if they wish.

I think it should be killed entirely, and that's what I'm going
to do.
