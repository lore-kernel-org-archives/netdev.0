From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 1.2 released
Date: Wed, 23 Jun 2004 09:44:02 -0400
Sender: prism54-users-bounces@prism54.org
Message-ID: <20040623134402.GE6253@ruslug.rutgers.edu>
References: <20040623064321.GX6253@ruslug.rutgers.edu>
	<20040623091403.GA4999@fluff>
	<346D1DC2D46433D94FB41A74@[192.168.1.22]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <prism54-users-bounces@prism54.org>
To: prism54-users@prism54.org
Content-Disposition: inline
In-Reply-To: <346D1DC2D46433D94FB41A74@[192.168.1.22]>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-users>
List-Post: <mailto:prism54-users@prism54.org>
List-Help: <mailto:prism54-users-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=subscribe>
Errors-To: prism54-users-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 23, 2004 at 11:29:58AM +0200, Claas Hilbrecht wrote:
> --Am Mittwoch, 23. Juni 2004 11:14 +0200 Richard Atterer 
> <richard@list04.atterer.net> schrieb:
> 
> >On Wed, Jun 23, 2004 at 02:43:21AM -0400, Luis R. Rodriguez wrote:
> >>* A ton of bugs were fixed
> >
> >Does this include a fix for the problem reported by Claas Hilbrecht and
> >me, that a prism54 host in master mode would take down the network once
> >you tried to transmit more than a few kB/sec?
> 
> I don't think so, since the ChangeLog doesn't contain any reference to my 
> bug report. And as you can see, none of the developers responded to my bug 
> report yet: http://prism54.org/cgi-bin/bugzilla/show_bug.cgi?id=87
> 
> After the bug report I switch the network to Ad-hoc mode and didn't have 
> any problems so far. So I really think this is a driver problem or firmware 
> issue.
> 

We'll have to reproduce first. We will look into it though.

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
