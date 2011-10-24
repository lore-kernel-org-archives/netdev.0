From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] Re: [PATCH 5/6] xen/netback: Enable netback on HVM
 guests
Date: Mon, 24 Oct 2011 10:19:08 -0400
Message-ID: <20111024141908.GA2435@phenom.dumpdata.com>
References: <1319124957-32269-1-git-send-email-dgdegra@tycho.nsa.gov>
 <1319124957-32269-6-git-send-email-dgdegra@tycho.nsa.gov>
 <1319448669.3385.161.camel@zakaz.uk.xensource.com>
 <20111024.053419.1995560587557035685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org,
	dgdegra@tycho.nsa.gov, xen-devel@lists.xensource.com,
	david.vrabel@citrix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:26928 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172Ab1JXOT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 10:19:26 -0400
Content-Disposition: inline
In-Reply-To: <20111024.053419.1995560587557035685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2011 at 05:34:19AM -0400, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Mon, 24 Oct 2011 10:31:08 +0100
> 
> > On Thu, 2011-10-20 at 16:35 +0100, Daniel De Graaf wrote:
> >> Signed-off-by: Daniel De Graaf <dgdegra@tycho.nsa.gov>
> > 
> > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > 
> > Normally netback patches would go in via the networking subsystem
> > maintainer's tree but since this depends on core Xen patches from this
> > series and is unlikely to conflict with anything in the net-next tree I
> > suspect it would make more sense for Konrad to take this one.
> > 
> > David (Miller) does that work for you?
> 
> Yes, it does.

OK, Can I stick Acked-by: David Miller on that patch?

Thank you.
