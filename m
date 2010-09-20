From: David Miller <davem@davemloft.net>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 11:22:13 -0700 (PDT)
Message-ID: <20100920.112213.42810338.davem@davemloft.net>
References: <87pqwff2bd.fsf@small.ssi.corp>
	<4C90EDF3.8010401@hp.com>
	<87bp7vnnpj.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757100Ab0ITSVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:21:54 -0400
In-Reply-To: <87bp7vnnpj.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Sat, 18 Sep 2010 16:14:16 +0200

> Below, UMIP is configured w/o any additional delay before RS emission on
> that interface. No DHCP running either:
> 
> 15:40:22.984311 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
> 15:40:26.984845 ethertype IPv6 (0x86dd), length 62: :: > ff02::2: ICMP6, router solicitation, length 8
> 15:40:26.989264 ethertype IPv6 (0x86dd), length 158: fe80::224:d5ff:fed4:476c > ff02::1: ICMP6, router advertisement
> 
> David, any idea on where this may come from and how to track the cause?

I have no context, what's the exact problem?
