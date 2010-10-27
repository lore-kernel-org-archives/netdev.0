From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Wed, 27 Oct 2010 17:01:39 -0400
Message-ID: <4CC89333.1040407@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net> <1288103614.2622.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao102.cox.net ([68.230.240.8]:51990 "EHLO
	eastrmmtao102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757081Ab0J0VBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 17:01:41 -0400
In-Reply-To: <1288103614.2622.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, tests with your fixes and with the smp barrier corrections are
looking positive.  More testing is needed before a final verdict is in
however -- the load test crashed after 8 hours due to an application bug
that we're working on fixing now.

Joe Buehler

