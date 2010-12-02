From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Thu, 02 Dec 2010 08:36:30 -0500
Message-ID: <4CF7A0DE.2050706@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net>	 <1288103614.2622.0.camel@edumazet-laptop>  <4CC89333.1040407@cox.net> <1288213502.2658.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtai110.cox.net ([68.230.240.29]:55652 "EHLO
	eastrmmtai110.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551Ab0LBNlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 08:41:39 -0500
In-Reply-To: <1288213502.2658.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have had no further problems with crashes.  The SMP memory barrier
fixes seem to have been the final piece that was missing.

Thanks for all the help, you guys are great.

Joe Buehler

