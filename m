From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] s390: claw network device driver
Date: Wed, 30 Mar 2005 08:49:04 +0100
Message-ID: <OFC1333756.61788013-ON41256FD4.002A627F-41256FD4.002AF205@de.ibm.com>
References: <4249B4F4.4050205@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Frank Pavlic <PAVLIC@de.ibm.com>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <4249B4F4.4050205@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> That's OK with me.  As an example, on the MIPS side of things, Ralf
> sends most MIPS stuff straight to Linus, but I queue all his
> drivers/net/* patches into my queue, and that gets submitted separately
> (though just as rapidly) upstream with other net driver changes.

Ok then, lets make it so. Frank creates the patches and sends them to
Jeff. Less work for me, I certainly like it :-))

> I certainly do recognize that qeth, in particular, is a network driver
> unlike all others in the kernel ;-)

Oh yes, that driver is a VERY different beast.

blue skies,
   Martin

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH
