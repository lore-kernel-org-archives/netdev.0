From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ATM] iphase: doesn't call phy->start due to a bogus
 #ifndef
Date: Sat, 14 Jun 2008 16:59:35 -0700 (PDT)
Message-ID: <20080614.165935.136299075.davem@davemloft.net>
References: <20080614.163522.127295395.davem@davemloft.net>
	<200806142345.m5ENjCuR006220@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755732AbYFNX7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 19:59:34 -0400
In-Reply-To: <200806142345.m5ENjCuR006220@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Sat, 14 Jun 2008 19:45:12 -0400

> In message <20080614.163522.127295395.davem@davemloft.net>,David Miller writes:
> >> i will submit to davem with the next batch of atm patches.
> >
> >Please do so soon, I've been waiting (too) patiently.
> 
> ok.  they would need to go on 2.6.27 though.  are you taking
> those at the moment?

Yes I am, but some of those changes are bug fixes and thus should be
submitted for 2.6.26

As I often indicate here, my two trees are:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

for "bug fix current release" stuff and:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git

for "features/cleanups bound for next release".

So please post those patches relative to that, as appropriate.
