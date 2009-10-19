From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [OT] ntop / GPL (was Re: PF_RING: Include in main line kernel?)
Date: Mon, 19 Oct 2009 07:12:32 +0000
Message-ID: <20091019071232.GA6464@ff.dom.local>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <4AD60053.1030804@gmail.com> <20091018124706.GG27747@prithivi.gnumonks.org> <20091019055521.GA5948@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org,
	Luca Deri <deri@ntop.org>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:42350 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbZJSHMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 03:12:34 -0400
Received: by fxm28 with SMTP id 28so4776025fxm.18
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 00:12:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091019055521.GA5948@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 05:55:21AM +0000, Jarek Poplawski wrote:
> On Sun, Oct 18, 2009 at 02:47:06PM +0200, Harald Welte wrote:
> > Hi Jarek, Brad, Luca,
> > 
> > [putting my gpl-violations.org hat on]
> > 
> > On Wed, Oct 14, 2009 at 06:46:11PM +0200, Jarek Poplawski wrote:
> > > Brad Doctor wrote, On 10/14/2009 04:33 PM:
> > > 
> > > > Download ntop
> > > > 
> > > > ntop is distributed under the GNU GPL. In order to be entitled to download
> > > > ntop you must accept the GNU license. 
> > > 
> > > I can't find such a thing neither in GNU GPL v2:
> > 
> > This is true.  The GPL does never need to be accepted for mere use (i.e.
> > running) the program.  This is at least true for the continental european
> > copyright systems, where any legally obtained copy of a program implicitly
> > carries the permission for running the program.  Only for any other activity
> > you will need to accept the license.
> > 
> > but, like others posted in this thread, ntop is not the PF_RING code.
> 
> ntop doesn't matter here at all:

Or more precisely: "ntop is not PF_RING code" doesn't matter here,
because it all suggests we have a false statement wrt. PF_RING.
(But Brad acknowledged this needs the change.)

> 
> if ((X uses the stock GPL license.) &&
>     (Y is distributed under the GNU GPL) &&
>     (In order to be entitled to download Y
>      you must accept the GNU license.) &&
>     (The GPL does never need to be accepted for mere use.))
> 
> 	is logically false.
> 
> BTW, legal systems don't matter here at all.

IOW: if this point of GNU GPL isn't true for some copyright system,
means GNU GPL can't be valid in such a system.

Jarek P.
