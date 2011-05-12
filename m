From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Fri, 13 May 2011 00:54:58 +0200
Message-ID: <20110512225458.GA19573@uio.no>
References: <20110506171249.GA29942@uio.no>
 <1304761486.2821.945.camel@edumazet-laptop>
 <20110507095910.GC30492@uio.no>
 <20110512.155221.59681200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:52775 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab1ELWzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:55:07 -0400
Content-Disposition: inline
In-Reply-To: <20110512.155221.59681200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 03:52:21PM -0700, David Miller wrote:
>>> I cooked for you the official patch and made sure it worked with a RED
>>> ECN setup, and one ipv6 tcp xmit.
>> Great, thanks :-) This looks good to me.
> Applied, thanks everyone.

Do you think it would be possible to get it backported to stable kernels?
(I've been told getting it into the 2.6.32.x series is the easiest way to get
it into Debian stable, and I guess it should be a candidate.)

/* Steinar */
-- 
Homepage: http://www.sesse.net/
