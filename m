From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 2 Jun 2009 17:29:32 +0900
Message-ID: <20090602172932.d8b0c72a.usui@mxm.nes.nec.co.jp>
References: <1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
	<1243893963.3966.325.camel@dogo.mojatatu.com>
	<20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
	<20090602072436.GB4239@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:62680 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759123AbZFBIeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 04:34:25 -0400
In-Reply-To: <20090602072436.GB4239@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Jun 2009 07:24:36 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Tue, Jun 02, 2009 at 03:59:19PM +0900, Minoru Usui wrote:
> > On Mon, 01 Jun 2009 18:06:03 -0400
> > jamal <hadi@cyberus.ca> wrote:
> > 
> > > On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:
> > > 
> > > > 
> > > > Actually, I'd insist with the old rock and handling that other rude
> > > > u32 case, at least until it's fixed in place. So I attach my version
> > > > of your patch (additionally I removed a pair of braces because of
> > > > checkpatch warning).
> > > 
> > > Sure, it doesnt complicate anything - Minoru, this is the version to go
> > > for.
> > 
> > I've tested Jarek's patch #1(for cls_api.c).
> > It works fine to me. Thanks Jarek.
> > 
> > 	Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Actually, as far as I can remember, it's your patch with slight
> modifications by Jamal and me. So please Minoru, resend this patch
> as Jamal previously suggested: with your changelog and Jamal's,
> plus maybe mine (if you don't mind) signed-off-by's.
> 
> Thanks,
> Jarek P.

OK. Thank you for your advise.
I'll resend the patch as a new thread.
-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
