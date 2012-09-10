From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [tcpdump-workers] Modular arithmetic
Date: Mon, 10 Sep 2012 07:49:28 -0700
Message-ID: <20120910144928.GN17289@tassilo.jf.intel.com>
References: <20120905213941.03c85968@arrowsmith>
 <C71A36A8-08D2-4D3D-AF2B-EF89FEECE1A6@alum.mit.edu>
 <20120906073615.693d14e0@arrowsmith>
 <46AB14E3-73F4-41FA-8086-F1D663AF4549@alum.mit.edu>
 <20120907074910.2df46817@arrowsmith>
 <20120908030311.GM17289@tassilo.jf.intel.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: George Bakos <gbakos@alpinista.org>,
	tcpdump-workers@lists.tcpdump.org,
	Jay Schulist <jschlst@samba.org>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16335 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab2IJOt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 10:49:29 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What about the other OS - eg all the BSDs?
> I had a vague idea that BPF was supposed to be reasonable portable.

Linux already has a variety of BPF extensions I believe.
But most of them were not targetted for tcpdump, but for other tools.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only
