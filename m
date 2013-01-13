From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Sat, 12 Jan 2013 18:03:43 -0800
Message-ID: <1358042623.20249.1603.camel@edumazet-glaptop>
References: <20130112.155651.1165922449897847275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:53964 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab3AMCDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 21:03:47 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so1569950pbc.4
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 18:03:47 -0800 (PST)
In-Reply-To: <20130112.155651.1165922449897847275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-12 at 15:56 -0800, David Miller wrote:
> 1) Fix regression allowing IP_TTL setting of zero, fix from Eric
>    Dumazet.

To be fair, I added this bug some time ago, and Cong Wang did the fix ;)

Thanks !
