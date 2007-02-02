From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH]ip_auto_config bug in 2.6.20-rc6
Date: Fri, 2 Feb 2007 16:47:21 +0100
Message-ID: <F6AD7E21CDF4E145A44F61F43EE6D939CBCFCB@tmnt04.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Netdev" <netdev@vger.kernel.org>,
	"Linux-Kernel" <linux-kernel@vger.kernel.org>
To: "Thomas Bogendoerfer" <tsbogend@alpha.franken.de>,
	"Jan Engelhardt" <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 147.175.241.83.in-addr.dgcsystems.net ([83.241.175.147]:20203
	"EHLO tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1945945AbXBBPrY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 10:47:24 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Bogendoerfer [mailto:tsbogend@alpha.franken.de] 
> Sent: 02 February 2007 16:18
> To: Jan Engelhardt
> Cc: Joakim Tjernlund; Netdev; Linux-Kernel
> Subject: Re: [PATCH]ip_auto_config bug in 2.6.20-rc6
> 
> On Fri, Feb 02, 2007 at 02:27:29PM +0100, Jan Engelhardt wrote:
> > >> I think this is a bug since I am not using a NFS root FS.
> > 
> > I just wonder why IP_PNP has not been obsoleted and removed 
> from the 
> > tree yet, given that initramfs is the advertised way to do so such 
> > things.
> 
> I hope this will not happen. Using BOOTP/NFS makes kernel hacking much
> easier on not yet supported machines, which offer tftp in 
> their firmware.
> 
> Thomas.

Just want to add a me too :)

 Jocke

PS.
   This is the first mail I have received in response to my postings,
please
   CC me on any replies.
