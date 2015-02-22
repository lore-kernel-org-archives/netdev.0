From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sun, 22 Feb 2015 01:41:51 +0100
Message-ID: <20150222004151.GA4947@louise.pinerecords.com>
References: <20150203100816.GA5807@louise.pinerecords.com>
 <20150203104214.GG24751@breakpoint.cc>
 <20150210154536.GB16264@breakpoint.cc>
 <20150221101512.GB17223@louise.pinerecords.com>
 <20150221103104.GA26574@breakpoint.cc>
 <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150221190507.GA25687@louise.pinerecords.com>
 <1424548447.5565.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from louise.pinerecords.com ([213.168.185.253]:39358 "EHLO
	louise.pinerecords.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbBVAmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 19:42:14 -0500
Content-Disposition: inline
In-Reply-To: <1424548447.5565.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Sure, just did.  Unfortunately, 3.19.0 + 0bec3b70 + this patch results
> > in a driver that retains the problem.
> 
> OK, could you test following patch instead ?

Yup, but tough luck: 3.19.0 + 0bec3b70 + this patch -> problem present.

-- 
Tomas Szepe <szepe@pinerecords.com>
