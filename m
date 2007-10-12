From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: add PCI error recovery support
Date: Fri, 12 Oct 2007 10:46:47 -0700
Message-ID: <1192211207.4795.4.camel@dell>
References: <20070718234826.GO5771@austin.ibm.com>
 <20070726225737.GK9876@austin.ibm.com> <1185498720.7922.85.camel@dell>
 <20070802231232.GL26837@austin.ibm.com>
 <1186100019.18322.77.camel@dell>
 <20071012163821.GA11913@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, "netdev" <netdev@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1643 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757408AbXJLQun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 12:50:43 -0400
In-Reply-To: <20071012163821.GA11913@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-12 at 11:38 -0500, linas@austin.ibm.com wrote:
> Hi,
> 
> On Thu, Aug 02, 2007 at 05:13:39PM -0700, Michael Chan wrote:
> > On Thu, 2007-08-02 at 18:12 -0500, linas@austin.ibm.com wrote:
> > > On Thu, Jul 26, 2007 at 06:12:00PM -0700, Michael Chan wrote:
> > > > On Thu, 2007-07-26 at 17:57 -0500, linas@austin.ibm.com wrote:
> > > > > [... PCI error recovery patches for tg3 ...]
> > > > 
> > > > Thanks.  We will review and submit probably in 2.6.24.
> > > 
> > > OK, thanks. Not to nag, but it helps to get these into susbsystem 
> > > maintainer trees well before then, as otherwise the 2.6.24 window 
> > > will get missed (seeing how I just missed 2.6.23 ..)
> > 
> > Yes, I know.  David Miller hasn't opened up a 2.6.24 tree yet.  We'll
> > probably have a number of patches to be submitted for 2.6.24, and we'll
> > add this one to the set.  Thanks.
> 
> Did the patch make it in?  Now seems to be the time ...
>
> --linas
> 
> p.s. I'll send a generic MSI patch to the PCI mailing list; it appears 
> the MSI issue is generic, affecting lots of adapters.
> 

We'll rediff the patch against the latest net-2.6 tree once you post the
MSI patch.  We'll also need IBM to do some testing on it.

Thanks.

