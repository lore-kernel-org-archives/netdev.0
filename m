From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull upstream-fixes branch of wireless-2.6
Date: Thu, 20 Apr 2006 05:00:10 -0400
Message-ID: <44474D9A.3000301@garzik.org>
References: <20060420011232.GA9268@tuxdriver.com> <200604201051.03881.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, akpm@osdl.org, torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:29318 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750759AbWDTJAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 05:00:15 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200604201051.03881.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 20 April 2006 03:12, John W. Linville wrote:
>>       bcm43xx: fix dyn tssi2dbm memleak
>>       bcm43xx: fix pctl slowclock limit calculation
>>       bcm43xx: sysfs code cleanup
> 
> These are already in -mm and on their way into linus's tree.
> Is it possible to cause problems?
> If not, fine. If yes, we need some clearly defined rules where
> to put patches and a clearly defined statement of how often
> patches are pushed upstream.

Ideally, patches should be sent to John, who will send me -> Linus.  If 
they are bug fixes, the turnaround can be same once I get them from John 
(and Linus is taking patches).

That's always been the standard route:  wireless patches -> wireless 
maintainer.

	Jeff



