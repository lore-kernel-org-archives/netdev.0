From: Meelis Roos <mroos@linux.ee>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Mon, 20 Feb 2012 14:04:14 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1202201403000.8004@math.ut.ee>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:38028 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab2BTMWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 07:22:04 -0500
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id 621B973DEBF
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 14:04:14 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id 2C2A4427977
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 14:04:14 +0200 (EET)
In-Reply-To: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Just tried 3.3-rc3+git and 3.3-rc4 on a generic i815+P3+e100 PC. It 
> crashes consistently during the end of bootup, getning oops in 
> __neigh_for_each_release during timer softirq. 3.2 works fine.

Hit send too fast - the first post-3.2 kernel I tried was 
3.3.0-rc3-00278-g4903062 and that failed, and 3.3-rc4 too.

-- 
Meelis Roos (mroos@linux.ee)
