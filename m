From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 07:54:51 +0000
Message-ID: <20090115075450.GB4190@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net> <20090114063909.GA4234@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net> <20090115065322.GA4190@ff.dom.local> <Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Chris Caputo <ccaputo@alt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:61632 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755376AbZAOHy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 02:54:58 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 07:26:28AM +0000, Chris Caputo wrote:
> On Thu, 15 Jan 2009, Jarek Poplawski wrote:
> > On Wed, Jan 14, 2009 at 06:02:04PM +0000, Chris Caputo wrote:
> > ...
> > > That said, I would not recommend just the three for -stable unless they 
> > > get a much wider amount of testing, on multiple platforms.  I don't see 
> > > that as likely to happen, plus Peter says they are incomplete, so maybe it 
> > > is just best to recommend that 2.6.28 users getting crashes while using 
> > > HTB try these specific patches at first, and then the rest of the patches 
> > > if they do not work.
...
> I hope you can forgive me, but since I have something that works on a 
> production machine, I am not in a position in which I can test this.

So, IOW, you don't recommend Peter's patches but prefere to use them,
and recommend my patches, but you are afraid of using them...
Of course I forgive you!-)

Jarek P.
