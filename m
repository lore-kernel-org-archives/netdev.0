From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: TCP out of memory - possible bug [3.18.0-rc3] / sched?
Date: Sun, 4 Jan 2015 22:39:43 +0100
Message-ID: <20150104213943.GB1710@x4>
References: <5457D095.9070502@qdot.me>
 <1415043704.1005.0.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150104084240.GA1710@x4>
 <1420405287.32621.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tomasz Mloduchowski <q@qdot.me>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:36761 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbbADVjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 16:39:45 -0500
Content-Disposition: inline
In-Reply-To: <1420405287.32621.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015.01.04 at 13:01 -0800, Eric Dumazet wrote:
> On Sun, 2015-01-04 at 09:42 +0100, Markus Trippelsdorf wrote:
> 
> > Any news on this issue?
> > 
> > I stumbled across the same problem today with 3.19.0-rc2:
> 
> What make you think it was fixed in 3.19.0-rc2 ?

Nothing.

> Have you tried a bisection ?

It was a one time event for me. So a bisection is out of the question.

But Tomasz wrote that he can reproduce the issue reliably.

Have you tried a bisection, Tomasz?

-- 
Markus
