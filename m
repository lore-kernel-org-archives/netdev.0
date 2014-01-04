From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: Pre-step for supporting GRO on vxlan traffic
Date: Sat, 4 Jan 2014 23:38:25 +0200
Message-ID: <CAJZOPZKPvAX7tz517NcDjVOhN8HHSKi94NCdtz-LeDS6cf=yfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54344 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:38:25 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so17032893pab.21
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:38:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 4, 2014 at 2:34 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  2 Jan 2014 15:27:55 +0200
>
>
> Never start conditional continuation lines with the conditional operator.
> Operators in a chain always _end_ a line, never begin them.



OK, will do. I will also rebase patch 2/2 on top of Jerry's gre-gro
patch to use the gro_find_xxx_by_type helpers.

Or.
