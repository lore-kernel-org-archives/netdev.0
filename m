From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label
Date: Thu, 24 May 2012 16:12:31 -0400 (EDT)
Message-ID: <20120524.161231.1058511318935925082.davem@davemloft.net>
References: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
	<20120521.023926.548567931208958037.davem@davemloft.net>
	<20120524195816.GA6487@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	allan.stephens@windriver.com, maloy@donjonn.com
To: paul.gortmaker@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20120524195816.GA6487@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 24 May 2012 15:58:16 -0400

> But for new TIPC development features, future direction, and things like
> that -- making the right call requires intimate understanding of TIPC
> and its users, which is something that a maintainer should have but
> something I know I don't have.  (A man has to know his limitations.)
> 
> In this context, I'm not talking about these three trivial patches; but
> more complicated stuff that I imagine will be floated in the future.
> 
> To that end, I can still review and call out issues in a crap patch when
> I see them.  But I'd like to see new stuff sent to netdev, so that folks
> smarter than me have a chance to catch when a patch appears generally OK
> but is architecturally the wrong direction etc.

For maintainership, taste is more important than deep knowledge of the
specific technology.  Worst case you ask the submitter to explain the
background of their change more thoroughly and that information is an
absolutely requirement in the commit message and code comments
anyways.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
