From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 20:18:31 +0930
Message-ID: <5370A6FF.3040902@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com> <DUB123-W15AFD3F815E035C19E3BF9ED4A0@phx.gbl>,<537082FC.2030505@davidnewall.com> <DUB123-W6BB791EB7730D01668FA4ED350@phx.gbl>,<5370A1A8.50604@davidnewall.com> <DUB123-W1083564F91F3902A8BDF67ED350@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Lukas Tribus <luky-37@hotmail.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:33937 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbaELKsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 06:48:36 -0400
In-Reply-To: <DUB123-W1083564F91F3902A8BDF67ED350@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/14 20:01, Lukas Tribus wrote:
>> >I don't suppose it's so old that anyone would be unsure about
>> >a change which might have fixed the problem since then.
> I disagree.


Oh, excellent.  You must know about a very recent patch that would fix 
the problem.  Please, point me in the right direction.

>> >This is a bug. Let's not stand on ceremony. Let's fix it.
> So you are not willing to test latest kernels, but expect the
> developers here to fix the bug?

Yes, I do expect developers to look at the bug even though I haven't 
checked the absolutely, positively, hottest-off-the-press, latest 
kernel.  That's what developers of serious software do: they treat 
serious bug reports seriously and with respect.  They don't engage in 
bloody-mindedness.  They don't grasp for excuses to ignore problems.  
Not unless they don't care about what they develop, and I happen to know 
that Linux developers care very passionately about the software.

Developers aren't going to take my word that the problem exists, but 
will try to reproduce it for themselves.  The purpose of trying vanilla 
kernels is to pre-qualify bugs, so that they don't waste their time 
chasing phantoms.  I've done that.  I've pre-qualified it; there's a bug.

Do you have an actual reason to think that this bug, which clearly has 
been undiagnosed for quite some time, has been fixed.  Because that 
would justify telling me to try a newer kernel.  If you don't, you're 
just being officious.
