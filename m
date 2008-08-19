From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 14:50:36 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808191446560.3324@nehalem.linux-foundation.org>
References: <alpine.LFD.1.10.0808191411390.3324@nehalem.linux-foundation.org> <20080819.142735.179034162.davem@davemloft.net> <alpine.LFD.1.10.0808191432040.3324@nehalem.linux-foundation.org> <20080819.144015.40311904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52152 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759620AbYHSVuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 17:50:39 -0400
In-Reply-To: <20080819.144015.40311904.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Aug 2008, David Miller wrote:
> 
> But I think you're throwing the baby out with the bath water, the
> majority of that pull contained legitimate real bug regression fixes.

.. and notice how I 

 (a) took it

and

 (b) am asking for you to be more careful?

In other words, I would be a lot happier if you didn't say "majority". I 
would be a ton happioer if you could HONESTLY say that every single one 
was a regression.

And the thing is, you cannot. Some of the ones I pointed you to were 
actually regressions due to _other_ patches you had much too happily sent 
me after the merge window had already closed).

> That's why some other developers are coming out of the woods and
> defending me, they don't have to do that, but they do it because they
> feel I'm being slighted at least a little bit.

Umm. The only defending I have seen was a F*CKING DISGRACE, since nobody 
apparently had the balls to stand up and admit that the whole problem 
happened after -rc1 in the first place!

In other words, the "defense" was just making excuses for EXACTLY the 
behaviour I'm trying to tell you shouldn't have happened in the first 
place.

Please. You're still making excuses for this, even after I pointed out 
that ALL of the problems with the whole loopback driver thing happened 
after the merge window. 

			Linus
