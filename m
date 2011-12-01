From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] red: make burst optional
Date: Thu, 1 Dec 2011 09:24:07 -0800
Message-ID: <20111201092407.330d8c90@nehalam.linuxnetplumber.net>
References: <1322688891.2602.15.camel@edumazet-laptop>
	<1322689213.2602.18.camel@edumazet-laptop>
	<1322691053.2602.24.camel@edumazet-laptop>
	<CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
	<1322693086.2602.28.camel@edumazet-laptop>
	<1322737471.2335.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1322749559.2335.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39611 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826Ab1LARYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:24:10 -0500
In-Reply-To: <1322749559.2335.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 Dec 2011 15:25:59 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Documentation advises to set burst to (min+min+max)/(3*avpkt)
> 
> Let tc do this automatically if user doesnt provide burst himself.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Both applied.
