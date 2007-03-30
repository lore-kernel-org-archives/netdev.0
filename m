From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 22:48:15 -0400
Message-ID: <20070330024815.GA18574@gospo.rdu.redhat.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death> <460C4EFE.6030505@nortel.com> <20070330003630.GA18319@gospo.rdu.redhat.com> <460C658C.7090803@nortel.com> <460C672F.404@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945915AbXC3Cth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 22:49:37 -0400
Content-Disposition: inline
In-Reply-To: <460C672F.404@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 07:26:07PM -0600, Chris Friesen wrote:
> Chris Friesen wrote:
> > Andy Gospodarek wrote:
> > 
> >> If you are looking for a decent source for patches you could consider
> >> downloading the latest source-rpm from RHEL4/CentOS4.  The bonding
> >> driver in those releases have been updated to much later code and I can
> >> tell you from personal experience they work pretty well.
> 
> > I'm just about to load a kernel with a backport of bonding from 2.6.14. 
> >  I'll try it out and if it doesn't help I'll try the RHEL4 one.
> 
> No joy on the 2.6.14 backport, so I guess I'll try the RHEL4 route.
> 

Ah, ok.  I'm not too sure how different the 2.6.9 and 2.6.10 bonding
code was, so it might take a little tweaking but I'm guessing there
won't be significant differences.
