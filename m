From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Re: Modular arithmetic
Date: Mon, 10 Sep 2012 11:41:54 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE5@saturn3.aculab.com>
References: <20120905213941.03c85968@arrowsmith>
	<C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
	<20120906073615.693d14e0@arrowsmith>
	<46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
	<20120907074910.2df46817@arrowsmith>
	<20120908030311.GM17289@tassilo.jf.intel.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
	<1347269124.1234.1326.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Schulist <jschlst@samba.org>,
	Andi Kleen <ak@linux.intel.com>, tcpdump-workers@lists.tcpdump.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
Content-class: urn:content-classes:message
In-Reply-To: <1347269124.1234.1326.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

> > What about the other OS - eg all the BSDs?
> > I had a vague idea that BPF was supposed to be reasonable portable.
> 
> Yes, does it mean BPF is frozen ?
> 
> Or is BSD so hard to update these days ?

Not really - but it some other places that need updating in order
to make this useful for cross-platform tools (like tcpdump).

The 'real fun (tm)' happens when NetBSD tries to run Linux binaries
that include the Linux libpcap.

	David
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
