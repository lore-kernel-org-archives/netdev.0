From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Sat, 13 Jun 2009 09:00:10 +0200
Message-ID: <4A334E7A.5020805@gmail.com>
References: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com>	<20090611.170948.66762524.davem@davemloft.net>	<ba4215e10906120519o35358caducfdd253c9f8d8bd2@mail.gmail.com> <20090612.170128.213931980.davem@davemloft.net>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, nico@cam.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:34730 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbZFMHAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 03:00:11 -0400
Received: by ewy6 with SMTP id 6so3583256ewy.37
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2009 00:00:12 -0700 (PDT)
In-Reply-To: <20090612.170128.213931980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I don't expect anyone to be required to read a data-sheet just to
> prevent some link mode settings.
>
> If the driver isn't clean enough to make a change like that easy,
> that's a bug.
>
> This is just a scarecrow argument.
>   
Ok if you like.

But please reply to the rest of that message, in particular explain why,
having publicly stated you would accept an implementation of Nicolas'
idea, you are now back pedaling. I'm quite prepared to be told that the
code itself is not good enough yet (with indications of how to improve
it) but we're not even discussing the code.

The impression (and I sincerely hope I am wrong) this gives me is that
when you accepted the idea in principle you didn't think anyone would
actually step up and write the code [presumably because us embedded
people are too busy working on our quick hacks]. Well I did and now I'm
calling upon you to keep your word.

At the end of the day you are the networking maintainer and I'm a no
name so you can tell me to go jump in the lake. But think a little about
the message that would send first. To the best of my knowledge I
respected the linux development process by discussing first and
apparently reaching a consensus - it's not like I jumped in with a chunk
of code demanding it be merged. If I misunderstood the process please
tell me too.

Martin

