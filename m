From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 19:20:39 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008201911380.10591@obet.zrqbmnf.qr>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>  <1282321023.2484.285.camel@edumazet-laptop>  <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr>  <1282321600.2484.297.camel@edumazet-laptop>  <alpine.LSU.2.01.1008201832500.7497@obet.zrqbmnf.qr>
 <1282322155.2484.309.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55206 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882Ab0HTRUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 13:20:41 -0400
In-Reply-To: <1282322155.2484.309.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2010-08-20 18:35, Eric Dumazet wrote:
>>>/* Some
>>> * fine
>>> * comment
>>> */
>>>And it really is better
>>Looks unsymmetric
>Who said comments must be symmetric ?

I can live with sub-level maintainers' free interpretation of areas
not covered by CodingStyle, but top-level maintainers directly going
against the law of Linux code is outrageous! The system is
undeniable :)
