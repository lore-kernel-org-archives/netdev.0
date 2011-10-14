From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 19:33:04 +0200
Message-ID: <1318613584.2223.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318576791.2533.99.camel@edumazet-laptop>
	 <20111014.034224.1197576516015404466.davem@davemloft.net>
	 <1318579509.2533.110.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43086 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab1JNRcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 13:32:47 -0400
Received: by wwf22 with SMTP id 22so3794929wwf.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 10:32:46 -0700 (PDT)
In-Reply-To: <1318579509.2533.110.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 10:05 +0200, Eric Dumazet a =C3=A9cr=
it :

> This patch specifically addresses the OFO problem, trying to lower
> memory usage for machines handling lot of sockets (proxies for exampl=
e)

Well, thinking a bit more about it is needed, so zap the patch please.

Thanks
