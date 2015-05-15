From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [RFC] about "ipv6: tcp: fix flowlabel value in ACK messages send
 from TIME_WAIT"
Date: Sat, 16 May 2015 00:28:22 +0200
Message-ID: <55567306.5060908@enst-bretagne.fr>
References: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34185 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217AbbEOWeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 18:34:04 -0400
In-Reply-To: <1431438429.566.79.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

thanks for reporting this issue. The patch sent some seconds ago should
solve the problem.

Regards,

Florent.
