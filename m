From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Wed, 22 Oct 2008 09:03:24 -0400
Message-ID: <48FF249C.5040207@hp.com>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com> <200810221601.27588.jk@ozlabs.org> <1224653529.6597.40.camel@localhost.localdomain> <200810221635.10268.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-6
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeremy Kerr <jk@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:19628 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbYJVND1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 09:03:27 -0400
In-Reply-To: <200810221635.10268.jk@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeremy

Jeremy Kerr wrote:
> Hi Maxime,
> 
>> I sent a patch sunday (using git-format-patch/git-send-email), and
>> patchwork seems to have missed it, I can't see it even with all
>> filters removed.
> 
> There are some conditions where the parser will reject the patch 
> outright, usually due to character encoding breakages (either in the 
> email itself or the parser code).
> 
> If you could send me an mbox file containing the email, I'll see what's 
> going on (and add a testcase to patchwork).
> 

Oddly enough, none of this series made it to patchwork.

I've put all the patches here:

http://www.kernel.org/pub/linux/kernel/people/vxy/for_jkerr/

These were generated used git-format-patch and send via git-send-email
with git version 1.5.3.5.

-vlad
