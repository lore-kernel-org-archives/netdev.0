From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 22:40:32 +0200
Message-ID: <1342644032.2626.3651.camel@edumazet-glaptop>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
	 <1342643659.2626.3636.camel@edumazet-glaptop>
	 <20120718.133647.1948216070418950586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:37136 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423Ab2GRUkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:40:37 -0400
Received: by gglu4 with SMTP id u4so2057699ggl.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 13:40:36 -0700 (PDT)
In-Reply-To: <20120718.133647.1948216070418950586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 13:36 -0700, David Miller wrote:

> Do you really think it's faster/better in this case?  I did consider
> it.

No, but code is smaller ;)
