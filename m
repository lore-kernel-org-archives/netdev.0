From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 00:34:34 +0200
Message-ID: <33a54cfcfda7e50e43a7399780626869@kernel.crashing.org>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <20070815233721.91032366.billfink@mindspring.com> <alpine.LFD.0.999.0708161045360.25951@enigma.security.iitk.ac.in> <4952d3f536060c186f40c277dfc74194@kernel.crashing.org> <alpine.LFD.0.999.0708170945300.3666@enigma.security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Bill Fink <billfink@mindspring.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	davids@webmaster.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35515 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbXHQWkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 18:40:12 -0400
In-Reply-To: <alpine.LFD.0.999.0708170945300.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Now the second wording *IS* technically correct, but come on, it's
> 24 words long whereas the original one was 3 -- and hopefully anybody
> reading the shorter phrase *would* have known anyway what was meant,
> without having to be pedantic about it :-)

Well you were talking pretty formal (and detailed) stuff, so
IMHO it's good to have that exactly correct.  Sure it's nicer
to use small words most of the time :-)


Segher

