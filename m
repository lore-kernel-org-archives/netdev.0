From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] Fix warning for token-ring from sysctl checker
Date: Wed, 14 Nov 2007 18:28:10 -0600
Message-ID: <20071115002810.GA7337@lixom.net>
References: <20071113072313.GB16842@lixom.net> <20071113.211540.97775009.davem@davemloft.net> <m1r6is253v.fsf@ebiederm.dsl.xmission.com> <20071114084528.0f092739.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:51783 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247AbXKOA1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 19:27:07 -0500
Content-Disposition: inline
In-Reply-To: <20071114084528.0f092739.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 08:45:28AM -0800, Randy Dunlap wrote:
> On Wed, 14 Nov 2007 08:56:20 -0700 Eric W. Biederman wrote:
> 
> > David Miller <davem@davemloft.net> writes:
> > 
> > > From: Olof Johansson <olof@lixom.net>
> > > Date: Tue, 13 Nov 2007 01:23:13 -0600
> > >
> > >> As seen when booting ppc64_defconfig:
> > >> 
> > >> sysctl table check failed: /net/token-ring .3.14 procname does not match
> > > binary path procname
> > >> 
> > >> 
> > >> Signed-off-by: Olof Johansson <olof@lixom.net>
> > >
> > > Patch applied, thanks Olof.
> > 
> > No objections but I think we already have this fixed in the -mm tree.
> 
> Yes, I patched it several weeks ago and it's been in -mm for a while
> now.  Apparently too long.

Ah, sorry for the duplicate patch then. I must have missed it at the
original posting (and didn't search that far back and/or -mm before
posting it myself).


-Olof
