From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Sat, 7 May 2011 11:59:10 +0200
Message-ID: <20110507095910.GC30492@uio.no>
References: <bug-34322-10286@https.bugzilla.kernel.org/>
 <20110505144146.4bc1e744.akpm@linux-foundation.org>
 <1304694292.3066.29.camel@edumazet-laptop>
 <20110506171249.GA29942@uio.no>
 <1304761486.2821.945.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:45741 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948Ab1EGJ7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 05:59:18 -0400
Content-Disposition: inline
In-Reply-To: <1304761486.2821.945.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 07, 2011 at 11:44:46AM +0200, Eric Dumazet wrote:
> I cooked for you the official patch and made sure it worked with a RED
> ECN setup, and one ipv6 tcp xmit.

Great, thanks :-) This looks good to me.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
