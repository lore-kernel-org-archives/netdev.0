From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: 30 Jul 2004 16:27:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091219266.1029.470.camel@jzny.localdomain>
References: <20040730060348.GA22854@havoc.gtf.org>
	 <ea86ce220407301229522be64f@mail.gmail.com>
	 <20040730193515.GA11365@havoc.gtf.org>
	 <20040730131004.2be1274d.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, tmattox@gmail.com, netdev@oss.sgi.com,
        Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040730131004.2be1274d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-30 at 16:10, David S. Miller wrote:
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

Patches are needed for the driver to use that code. So its not entirely
dead code i.e it is referenced from fastroute enabled drivers.
Sample (really old) code found at:
http://ftp.iasi.roedu.net/mirrors/ftp.inr.ac.ru/ip-routing/fastroute/

 
> I think it should be killed entirely, and that's what I'm going
> to do.

Nod from here. 
Before you kill it lets hear from Ralf who is acquinted with someone
that uses it and sings praises of it (although i personaly dont believe
it ;->).

cheers,
jamal
