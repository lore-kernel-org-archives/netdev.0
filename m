From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: TOE brain dump
Date: 03 Aug 2003 21:52:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059943933.31901.3.camel@dhcp22.swansea.linux.org.uk>
References: <20030802140444.E5798@almesberger.net>
	 <3F2BF5C7.90400@us.ibm.com> <3F2C0C44.6020002@pobox.com>
	 <3F2C891B.7080004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Nivedita Singhvi <niv@us.ibm.com>,
   Werner Almesberger <werner@almesberger.net>, netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F2C891B.7080004@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2003-08-03 at 05:01, Ben Greear wrote:
> Jeff Garzik wrote:
> 
> > So, fix the other end of the pipeline too, otherwise this fast network 
> > stuff is flashly but pointless.  If you want to serve up data from disk, 
> > then start creating PCI cards that have both Serial ATA and ethernet 
> > connectors on them :)  Cut out the middleman of the host CPU and host 
> 
> I for one would love to see something like this, and not just Serial ATA..
> but maybe 8x Serial ATA and RAID :)

There is a protocol floating around for ATA over ethernet, no TCP layer
or nasty latency eating complexities in the middle
