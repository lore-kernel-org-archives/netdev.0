From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Thu, 27 Sep 2012 14:14:02 +0200
Message-ID: <1348748042.5093.1168.camel@edumazet-glaptop>
References: <5057455A.7050108@googlemail.com>
	 <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>
	 <1347979239.26523.267.camel@edumazet-glaptop>
	 <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>
	 <50643DA1.7070306@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gpiez@web.de
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58521 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab2I0MOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:14:07 -0400
Received: by bkcjk13 with SMTP id jk13so1650196bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 05:14:06 -0700 (PDT)
In-Reply-To: <50643DA1.7070306@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 12:50 +0100, Chris Clayton wrote:
> Just for information - I've pulled Linus' tree this morning and the 
> problem is still present. Also, Gunther Piaz has reported, via the 
> bugzilla entry, that he too has hit this regression.

I tried to reproduce the bug, and my kvm guests have no problem.

I guess you need to precisely describe how you setup your network, so
that I can reproduce the problem and eventually fix it.

Thanks
