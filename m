From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 00/51] Fix potential issues detected by Coverity
 tool
Date: Tue, 15 Aug 2017 09:14:43 -0700
Message-ID: <20170815091443.44367669@xeon-e3>
References: <20170812120510.28750-1-phil@nwl.cc>
        <20170815080725.1dbb42a0@xeon-e3>
        <20170815160432.GF16375@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35845 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753105AbdHOQOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:14:46 -0400
Received: by mail-pg0-f42.google.com with SMTP id i12so8306360pgr.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:14:46 -0700 (PDT)
In-Reply-To: <20170815160432.GF16375@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 18:04:32 +0200
Phil Sutter <phil@nwl.cc> wrote:

> On Tue, Aug 15, 2017 at 08:07:25AM -0700, Stephen Hemminger wrote:
> > On Sat, 12 Aug 2017 14:04:19 +0200
> > Phil Sutter <phil@nwl.cc> wrote:
> >   
> > > Covscan really wasn't amused (indicated by the number of patches in this
> > > series). Try to make it happy.
> > > 
> > > Phil Sutter (51):  
> [...]
> > >  40 files changed, 230 insertions(+), 168 deletions(-)
> > >   
> > 
> > I am not amused by large patchsets either.
> > It takes more time to review, and one comment means the whole series
> > has to be redone.  
> 
> OK, so should I send each patch individually (unless related to others)?
> 
> Thanks, Phil


Group like patches as needed. For example, all the ss patches.
