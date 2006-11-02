From: Meelis Roos <mroos@ut.ee>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 2 Nov 2006 11:12:32 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611021111360.1919@math.ut.ee>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
 <20061102.001643.30183952.davem@davemloft.net> <20061102.003953.55508453.davem@davemloft.net>
 <Pine.SOC.4.61.0611021042070.1919@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:37555 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1752759AbWKBJMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 04:12:47 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.SOC.4.61.0611021042070.1919@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Sure. Evenso, I did test full make after the single compile was fine (still 
> have it in my scrollback so here it is). So did I do anything wrong here or 
> do we have some dependencies broken somewhere or what?

Never mind - I discovered the warning on one box with SCTP enabled in 
config and tried the fix on a faster machine that unfortunately had SCTP 
disabled.

-- 
Meelis Roos (mroos@ut.ee)      http://www.cs.ut.ee/~mroos/
