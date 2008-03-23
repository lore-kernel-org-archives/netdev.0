From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel panic, ip_route_input, 2.6.25-rc6-git2
Date: Sun, 23 Mar 2008 19:17:55 +0200
Message-ID: <20080323171730.M39052@visp.net.lb>
References: <20080323073638.M89709@visp.net.lb> <20080323.031139.17629653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37716 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbYCWRSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 13:18:13 -0400
In-Reply-To: <20080323.031139.17629653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What can i do to increase usability?

On Sun, 23 Mar 2008 03:11:39 -0700 (PDT), David Miller wrote
> From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> Date: Sun, 23 Mar 2008 09:36:38 +0200
> 
> > Recently tested, it crashes also -git6 without lockdep compiled. So it 
seems 
> > actually networking code bug.
> 
> I'm still not so sure.
> 
> The IP is at ip_route_input but the rest of your backtrace
> shows an entirely different code path.
> 
> Nothing in the trace matches up, which severely decreases the
> usability of the debugging information you've provided.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

