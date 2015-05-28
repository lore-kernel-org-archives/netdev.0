From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net] bridge: fix br_multicast_query_expired() bug
Date: Thu, 28 May 2015 18:42:44 +0200
Message-ID: <20150528164243.GE2827@odroid>
References: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>,
	"Steinar H. Gunderson" <sesse@samfundet.no>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:54481 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502AbbE1QnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 12:43:00 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id 14ECD586627
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 18:42:54 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 04:42:54AM -0700, Eric Dumazet wrote:
> Intent of the code was to clear port field, not the pointer to querie=
r.

Acked-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
