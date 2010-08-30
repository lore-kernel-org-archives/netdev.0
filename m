From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Mon, 30 Aug 2010 13:47:10 -0700 (PDT)
Message-ID: <20100830.134710.191393198.davem@davemloft.net>
References: <AANLkTinrPcJwMs+frY7J_QKuNv1MDGRQAgPgwofuFydw@mail.gmail.com>
	<20100830.132502.68138403.davem@davemloft.net>
	<1283200212.2405.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, hannemann@nets.rwth-aachen.de, hagen@jauu.net,
	lars.eggert@nokia.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755809Ab0H3Uqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:46:55 -0400
In-Reply-To: <1283200212.2405.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Aug 2010 22:30:12 +0200

> Jerry, could you please send a man update ?
> 
> http://www.kernel.org/doc/man-pages/online/pages/man7/tcp.7.html
> 
> (To Michael Kerrisk <mtk.manpages@gmail.com> )

Yes, thanks for catching this Eric.
