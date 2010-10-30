From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6/udp: report SndbufErrors and RcvbufErrors
Date: Sat, 30 Oct 2010 16:17:30 -0700 (PDT)
Message-ID: <20101030.161730.112593891.davem@davemloft.net>
References: <a2ae895d871551a9b3ded9ce3874fe28.squirrel@imap.coplanar.net>
	<1288124842.2652.28.camel@edumazet-laptop>
	<1288172116.2709.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55479
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753026Ab0J3XRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 19:17:07 -0400
In-Reply-To: <1288172116.2709.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Oct 2010 11:35:16 +0200

> commit a18135eb9389 (Add UDP_MIB_{SND,RCV}BUFERRORS handling.)
> forgot to make the necessary changes in net/ipv6/proc.c to report
> additional counters in /proc/net/snmp6
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
