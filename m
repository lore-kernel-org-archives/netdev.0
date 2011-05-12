From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Thu, 12 May 2011 15:52:21 -0700 (PDT)
Message-ID: <20110512.155221.59681200.davem@davemloft.net>
References: <20110506171249.GA29942@uio.no>
	<1304761486.2821.945.camel@edumazet-laptop>
	<20110507095910.GC30492@uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yoshfuji@linux-ipv6.org
To: sgunderson@bigfoot.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752214Ab1ELWwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:52:53 -0400
In-Reply-To: <20110507095910.GC30492@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Date: Sat, 7 May 2011 11:59:10 +0200

> On Sat, May 07, 2011 at 11:44:46AM +0200, Eric Dumazet wrote:
>> I cooked for you the official patch and made sure it worked with a RED
>> ECN setup, and one ipv6 tcp xmit.
> 
> Great, thanks :-) This looks good to me.

Applied, thanks everyone.
