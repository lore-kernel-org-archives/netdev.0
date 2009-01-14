From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 15:19:14 +0200
Message-ID: <200901141519.14396.denys@visp.net.lb>
References: <20081010090426.GA6054@ff.dom.local> <20090114131257.GC6117@ff.dom.local> <1231938929.14825.6.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44147 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758278AbZANNTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 08:19:22 -0500
In-Reply-To: <1231938929.14825.6.camel@laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 January 2009 15:15:29 Peter Zijlstra wrote:
> >
> > Denys, since these three patches worked for Chris, I guess it's safer
> > to stay with 2.6.28 anyway (or my patches mentioned earlier in this
> > thread). rc1 is really not stable...
>
> Yeah, but those three patches have some holes in them still, so I cannot
> recommend just patching in those three.
I will test rc1-git4 on few units which is less important and have redundancy, 
and then will decide. Already i did this 3 patches, but i prefer complete 
solution. If i will hit any bug, at least i will do my best to report about 
this bugs and such way to help fix them :-)
