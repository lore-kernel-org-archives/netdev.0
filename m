From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] fq_codel: Fair Queue Codel AQM
Date: Sat, 12 May 2012 22:42:37 +0200
Message-ID: <1336855357.31653.1331.camel@edumazet-glaptop>
References: <1336752516.31653.196.camel@edumazet-glaptop>
	 <1336764650.31653.277.camel@edumazet-glaptop>
	 <1336774576.31653.289.camel@edumazet-glaptop>
	 <20120512.155555.1011024268184559052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org,
	dave.taht@bufferbloat.net, nichols@pollere.com, van@pollere.net,
	therbert@google.com, mattmathis@google.com, ycheng@google.com,
	shemminger@vyatta.com, maze@google.com, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36440 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756033Ab2ELUmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 16:42:44 -0400
Received: by wibhj8 with SMTP id hj8so522190wib.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 13:42:43 -0700 (PDT)
In-Reply-To: <20120512.155555.1011024268184559052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-12 at 15:55 -0400, David Miller wrote:

> I applied this with the WARN_ON_ONCE(1) removed but there was another
> problem.
> 
> When you include ping output in your commit message that "---" string
> told GIT that this was the end of the commit message when in fact
> there was more content including your signoff.
> 
> I caught it and fixed it up, but please be more mindful of this in
> the future.

Oops... I feel sorry and I fear this will happen again, because I use a
lot "ping". I'll try to remember this.

Thanks a lot David.
