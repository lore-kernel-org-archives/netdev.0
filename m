From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: MV643xx Ethernet 2.6 driver update
Date: Fri, 28 Jan 2005 10:06:22 +1100
Message-ID: <1106867182.6250.102.camel@gaston>
References: <20050117184019.GA24655@xyzzy> <41F8BACA.1020302@pobox.com>
	 <20050127201955.GC1452@xyzzy>  <41F94FBD.7000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@oss.sgi.com,
        Ralf Baechle <ralf@linux-mips.org>,
        Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41F94FBD.7000208@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-27 at 15:31 -0500, Jeff Garzik wrote:
> Thanks, pulled.  It will sit in netdev-2.6 queue (and thus -mm) for a 
> while, while I and others review it.  I admit I only gave it a quick 
> overview.
> 
> After a little while we'll push upstream.

Excellent ! I'll do some tests on pegasos here, it's a ppc machine using
this chipset as well. The previous driver was unuseable, and some
patches were floating around but it was still not really working
properly.

Ben.
