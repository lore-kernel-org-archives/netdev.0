From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 05:43:52 +0200
Message-ID: <1219203832.7591.207.camel@violet.holtmann.net>
References: <20080819.041706.261399060.davem@davemloft.net>
	 <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
	 <20080819.131454.223684377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42626 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbYHTDnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 23:43:49 -0400
In-Reply-To: <20080819.131454.223684377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > For example, those BT updates looked in no way like regression fixes. So 
> > what the f*ck were they doing there? And why do you think all those driver 
> > updates cannot cause new regressions? 
> 
> The BT bits were the only part I really considered borderline,
> and I was going to push back on Marcel.
> 
> But to be honest, I haven't seen bluetooth updates from him
> for such a long time I felt that being strict here would just
> exacerbate the problem.
> 
> Guess I was wrong.

as I explained to Linus, my current assumption was that documentation
updates and new driver stuff should go in quickly. You will not get any
of these from me anymore. Next time you only get the one regression fix
and all my queued up stuff in the next merge window.

Don't hold back if you think that a patch is not acceptable. Really, I
am using GIT for everything. Merging is no problem for me. I also do
backports in my -mh patch for the latest stable kernel. So there is no
extra work for me. It is just sending you a new email with another tree
to pull from :)

Regards

Marcel


