From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Fri, 26 May 2006 10:11:38 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605261008090.14762@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:52872 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751312AbWEZHLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 03:11:45 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4475FCFC.5000701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Meelis, it would really help if you could try 2.6.16 and in case
> that doesn't work 2.6.15 to give an idea about whether this is a
> recent regression or an old problem. We had a number of changes
> in this area in the last two kernel versions that could be related.

Unfortunatlety, 2.6.15 does not boot on this machine so I'm locked out 
remotely at the moment. Will see if I can find the boot cure - there 
used to be a Motorola Powerstack-specific patch to make it boot that 
Debian 2.6.18 and IIRC 2.6.12 packages included and that was integrated 
somewhere later - maybe it's missing fom 2.6.15.

-- 
Meelis Roos (mroos@linux.ee)
