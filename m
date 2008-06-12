From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: > try a more current kernel (e.g. 2.6.26-rc5).
Date: Thu, 12 Jun 2008 13:39:03 -0700
Message-ID: <20080612133903.5d28b961@extreme>
References: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com>
	<4851116A.6040805@trash.net>
	<43d009740806120524g78d066d2x95640fc8e01be625@mail.gmail.com>
	<485115EE.1040204@trash.net>
	<48517ACD.4020209@gmail.com>
	<48517D1C.7010308@gmail.com>
	<20080612201548.GA2472@ami.dom.local>
	<4851854E.7050505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: for.poige+linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52929 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733AbYFLUjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 16:39:09 -0400
In-Reply-To: <4851854E.7050505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jun 2008 04:21:34 +0800
Igor M Podlesny <for.poige+linux@gmail.com> wrote:

> On 2008-06-13 04:15, Jarek Poplawski wrote:
> > On Fri, Jun 13, 2008 at 03:46:36AM +0800, Igor M Podlesny wrote:
> >> On 2008-06-13 03:36, Jarek Poplawski wrote:
> 	[...]
> > Hm... hard to tell. This shouldn't happen and rebooting isn't a solution.
> > Try to eliminate this (is it patched kernel BTW?). Check your hardware
> > and maybe try a more current kernel (e.g. 2.6.26-rc5).
> 
> 	2.6.26 has changed something in sensors interface and Nvidia's driver could not be
> compiled for it as well. As far as I use TwinView I can afford just switching to not
> Nvidia's driver.
> 

And kernel developer's can not afford debugging closed source drivers.
