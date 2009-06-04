From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Thu, 4 Jun 2009 13:41:33 +0900
Message-ID: <20090604134133.dde9ddc6.usui@mxm.nes.nec.co.jp>
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
	<20090602155919.da89c08e.usui@mxm.nes.nec.co.jp>
	<1243948765.3966.397.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:48374 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbZFDFGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 01:06:38 -0400
In-Reply-To: <1243948765.3966.397.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Jun 2009 09:19:25 -0400
jamal <hadi@cyberus.ca> wrote:

> On Tue, 2009-06-02 at 15:59 +0900, Minoru Usui wrote:
> 
> > If we have to test Jarek's patch #2, I'll test it tomorrow.
> > What do you think Jamal?
> 
> Yes please - even if it is for reasons of givein Jarek some peace of
> mind;->
> If something goes seriously wrong with other classifiers because of the
> patch, and Jareks patch works, we can back out the current patch and fix
> it with that approach.

I've tested Jarek's patch #2 without patch #1.
It works fine, too. Thanks Jarek.

	Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
