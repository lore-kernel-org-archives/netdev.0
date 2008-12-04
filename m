From: David Miller <davem@davemloft.net>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 04 Dec 2008 10:18:05 -0800 (PST)
Message-ID: <20081204.101805.45306327.davem@davemloft.net>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	<Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
	<20081204185022.6108d19e@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, saverio.mascolo@gmail.com,
	netdev@vger.kernel.org
To: ldecicco@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34061
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752444AbYLDSSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 13:18:04 -0500
In-Reply-To: <20081204185022.6108d19e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca De Cicco <ldecicco@gmail.com>
Date: Thu, 4 Dec 2008 18:50:22 +0100

> Thank you for pointing out, we employed the kernel 2.6.24 with web100

That is so ancient, especially TCP wise, it isn't even funny.

And using the web100 patch adds yet more variables to the equation.

It doesn't really reflect what users are actually running in the world
today, not by a country mile.

You're not comparing what we're actually shipping in the kernel.org
kernel at all with your tests, which means your tests and results are
something close to useless for us.

I don't udnerstand why there are so many people who dice up their
kernels, or use very old kernels, then do some "research" and then
suggest we should change this or that with the kernel.org kernel as a
result.

Sorry, nobody here is going to take that seriously at all.
