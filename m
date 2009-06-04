From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Thu, 4 Jun 2009 06:34:45 +0000
Message-ID: <20090604063445.GA2683@ff.dom.local>
References: <1243776293.3966.241.camel@dogo.mojatatu.com> <20090531195557.GA2777@ami.dom.local> <1243813216.3966.254.camel@dogo.mojatatu.com> <20090601060638.GA4256@ff.dom.local> <1243861410.3966.268.camel@dogo.mojatatu.com> <20090601204957.GA2760@ami.dom.local> <1243893963.3966.325.camel@dogo.mojatatu.com> <20090602155919.da89c08e.usui@mxm.nes.nec.co.jp> <1243948765.3966.397.camel@dogo.mojatatu.com> <20090604134133.dde9ddc6.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:59615 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbZFDGet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 02:34:49 -0400
Received: by fxm9 with SMTP id 9so493423fxm.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 23:34:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090604134133.dde9ddc6.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2009 at 01:41:33PM +0900, Minoru Usui wrote:
> On Tue, 02 Jun 2009 09:19:25 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Tue, 2009-06-02 at 15:59 +0900, Minoru Usui wrote:
> > 
> > > If we have to test Jarek's patch #2, I'll test it tomorrow.
> > > What do you think Jamal?
> > 
> > Yes please - even if it is for reasons of givein Jarek some peace of
> > mind;->
> > If something goes seriously wrong with other classifiers because of the
> > patch, and Jareks patch works, we can back out the current patch and fix
> > it with that approach.
> 
> I've tested Jarek's patch #2 without patch #1.
> It works fine, too. Thanks Jarek.
> 
> 	Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

Thank you very much. So, as Jamal wrote, let's wait - hoping it won't
be needed...

Jarek P.

Btw., it seems your box needs time update:

Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Thu, 4 Jun 2009 13:41:33 +0900
...
Original-Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv.nec.co.jp (8.13.8/8.13.4) with ESMTP id n5455gP4006057;
	Thu, 4 Jun 2009 14:06:27 +0900 (JST)
