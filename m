From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 18:34:39 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008201832500.7497@obet.zrqbmnf.qr>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>  <1282321023.2484.285.camel@edumazet-laptop>  <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr> <1282321600.2484.297.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282321600.2484.297.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2010-08-20 18:26, Eric Dumazet wrote:

>> Actually,
>> 	/*
>> 	 * Some
>> 	 */
>> But that's in CodingStyle already. Always a good read, even if reread.
>
>Sorry, I documented David S. Miller choice, or else I would have
>mentioned CodingStyle :)
>
>	/* Some
>	 * fine
>	 * comment
>	 */
>
>And it really is better ;)

Looks unsymmetric, which is probably the reason CodingStyle was 
conceived differently in the first place.
