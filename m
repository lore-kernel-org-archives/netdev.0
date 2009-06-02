From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 2 Jun 2009 15:59:19 +0900
Message-ID: <20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
References: <1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<1243684218.3966.83.camel@dogo.mojatatu.com>
	<20090531081213.GC2756@ami.dom.local>
	<1243776293.3966.241.camel@dogo.mojatatu.com>
	<20090531195557.GA2777@ami.dom.local>
	<1243813216.3966.254.camel@dogo.mojatatu.com>
	<20090601060638.GA4256@ff.dom.local>
	<1243861410.3966.268.camel@dogo.mojatatu.com>
	<20090601204957.GA2760@ami.dom.local>
	<1243893963.3966.325.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:38153 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbZFBHEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 03:04:10 -0400
In-Reply-To: <1243893963.3966.325.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Jun 2009 18:06:03 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:
> 
> > 
> > Actually, I'd insist with the old rock and handling that other rude
> > u32 case, at least until it's fixed in place. So I attach my version
> > of your patch (additionally I removed a pair of braces because of
> > checkpatch warning).
> 
> Sure, it doesnt complicate anything - Minoru, this is the version to go
> for.

I've tested Jarek's patch #1(for cls_api.c).
It works fine to me. Thanks Jarek.

	Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

If we have to test Jarek's patch #2, I'll test it tomorrow.
What do you think Jamal?

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
