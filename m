From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Fri, 2 Jun 2006 16:18:06 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0606021617480.1298@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
 <Pine.SOC.4.61.0606011002180.13777@math.ut.ee> <447F2787.8010203@trash.net>
 <Pine.SOC.4.61.0606012346350.28838@math.ut.ee> <4480385C.7080405@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:19625 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751383AbWFBNSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 09:18:12 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4480385C.7080405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Very strange, this means that the initial table data must somehow
> be wrong, but for some reason it still seems to get past the
> size and offset checks for the filter table. I can't see how
> loading the filter table could fail after the "Finished chain .."
> messages without another message. Which kernel version did you
> perform these test on?

Yesterdays 2.6.17-rc5+git.

-- 
Meelis Roos (mroos@linux.ee)
