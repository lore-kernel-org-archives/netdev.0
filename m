From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 00/51] Fix potential issues detected by Coverity
 tool
Date: Tue, 15 Aug 2017 18:04:32 +0200
Message-ID: <20170815160432.GF16375@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170815080725.1dbb42a0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43287 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751119AbdHOQEd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:04:33 -0400
Content-Disposition: inline
In-Reply-To: <20170815080725.1dbb42a0@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 08:07:25AM -0700, Stephen Hemminger wrote:
> On Sat, 12 Aug 2017 14:04:19 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Covscan really wasn't amused (indicated by the number of patches in this
> > series). Try to make it happy.
> > 
> > Phil Sutter (51):
[...]
> >  40 files changed, 230 insertions(+), 168 deletions(-)
> > 
> 
> I am not amused by large patchsets either.
> It takes more time to review, and one comment means the whole series
> has to be redone.

OK, so should I send each patch individually (unless related to others)?

Thanks, Phil
