From: Michel Machado <michel@digirati.com.br>
Subject: Re: [PATCH 1/1] net: add dev_loopback_xmit() to avoid duplicate code
Date: Tue, 05 Jun 2012 09:23:33 -0400
Message-ID: <1338902613.2792.16.camel@Thor>
References: <1337782819.2779.20.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta113.f1.k8.com.br ([187.73.32.185]:41929 "EHLO
	mta113.f1.k8.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934090Ab2FENXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:23:40 -0400
In-Reply-To: <1337782819.2779.20.camel@Thor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>I'm getting really tired of saying this.
>
>As I announced several days ago, it is absolutely not appropriate
>to submit patches other than bug fixes at this time because we are
>in the merge window and the net-next tree is frozen.
>
>And even once I do announce here that the net-next tree is open
>once more, and patches like this one are appropriate, you must
>indicate in the subject line which of the 'net' or 'net-next'
>tree you are targetting your patch at.
>
>Please pay attention to what's going on, and what state the networking
>development trees are in, before submitting changes.

I am sorry. I'm still new to this process, and I clearly haven't found
my way yet. Accept my apology and consider that others making the same
mistake are likely trying to find their ways as well. Rest sure that I
do appreciate your time and work, I'll pay more attention on those time
windows.

Just to avoid bothering you further, should I resend this patch or not?
I saw at the link below that it's already marked as "Deferred".

http://patchwork.ozlabs.org/patch/160929/

Is there a link where I can check the state (i.e. open, frozen) of 'net'
and 'net-next' trees? I think keeping such page, and adding this link to
Documentation/SubmittingPatches would reduce similar mistakes.

-- 
[ ]'s
Michel Machado
