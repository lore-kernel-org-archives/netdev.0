From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 2 Jun 2009 07:24:36 +0000
Message-ID: <20090602072436.GB4239@ff.dom.local>
References: <1243684218.3966.83.camel@dogo.mojatatu.com> <20090531081213.GC2756@ami.dom.local> <1243776293.3966.241.camel@dogo.mojatatu.com> <20090531195557.GA2777@ami.dom.local> <1243813216.3966.254.camel@dogo.mojatatu.com> <20090601060638.GA4256@ff.dom.local> <1243861410.3966.268.camel@dogo.mojatatu.com> <20090601204957.GA2760@ami.dom.local> <1243893963.3966.325.camel@dogo.mojatatu.com> <20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:37727 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570AbZFBHYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:24:40 -0400
Received: by fxm12 with SMTP id 12so6278260fxm.37
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 00:24:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2009 at 03:59:19PM +0900, Minoru Usui wrote:
> On Mon, 01 Jun 2009 18:06:03 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:
> > 
> > > 
> > > Actually, I'd insist with the old rock and handling that other rude
> > > u32 case, at least until it's fixed in place. So I attach my version
> > > of your patch (additionally I removed a pair of braces because of
> > > checkpatch warning).
> > 
> > Sure, it doesnt complicate anything - Minoru, this is the version to go
> > for.
> 
> I've tested Jarek's patch #1(for cls_api.c).
> It works fine to me. Thanks Jarek.
> 
> 	Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Actually, as far as I can remember, it's your patch with slight
modifications by Jamal and me. So please Minoru, resend this patch
as Jamal previously suggested: with your changelog and Jamal's,
plus maybe mine (if you don't mind) signed-off-by's.

Thanks,
Jarek P.
