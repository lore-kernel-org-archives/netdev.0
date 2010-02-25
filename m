From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to
	entering networked mode
Date: Thu, 25 Feb 2010 08:24:57 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA2943070F1928@ala-mail09.corp.ad.wrs.com>
References: <20100224211507.GC15380@hmsreliant.think-freely.org><20100224.173811.264809559.davem@davemloft.net><29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
	<20100225.070620.236234509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org, hadi@cyberus.ca,
	tipc-discussion@lists.sourceforge.net, nhorman@tuxdriver.com
To: "David Miller" <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20100225.070620.236234509.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, February 25, 2010 10:06 AM

> > PS. I'm holding back on replying to other previous emails 
> from David 
> > and Neil in this thread since deciding how to fix the oops that 
> > triggered this whole discussion depends on whether or not 
> we're going 
> > to integrate the rest of TIPC 1.7 or not.
> 
> Are you out of your mind?
> 
> We're fixing the OOPS in the smallest and most expediant way possible.
> 
> Integrating all of TIPC 1.7 to fix this OOPS is utter and 
> pure insanity.

That's what I thought you'd say, but I still thought it was worth asking
the question.  I've got no problem with limiting the changes to the
matter currently at hand.

-- Al

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
