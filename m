From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Thu, 25 May 2006 23:15:23 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605252310230.28494@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:8646 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751144AbWEYUP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:15:28 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4475FCFC.5000701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> http://bugzilla.kernel.org/show_bug.cgi?id=6613
>
> Meelis, it would really help if you could try 2.6.16 and in case
> that doesn't work 2.6.15 to give an idea about whether this is a
> recent regression or an old problem. We had a number of changes
> in this area in the last two kernel versions that could be related.

2.6.16 doesn't work either.

Tried 2.6.8-3 from sarge package, it is working.

Compiling 2.6.15 now...

-- 
Meelis Roos (mroos@linux.ee)
