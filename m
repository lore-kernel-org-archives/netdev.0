From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: early demux should be aware of fragments
Date: Fri, 29 Jan 2016 12:57:36 -0800
Message-ID: <1454101056.7627.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160127.170203.701586924097928864.davem@davemloft.net>
	 <1454080926.7627.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.122437.2258453843319826058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, pshelar@ovn.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34612 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbcA2U5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 15:57:38 -0500
Received: by mail-pa0-f65.google.com with SMTP id yy13so4047310pab.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 12:57:38 -0800 (PST)
In-Reply-To: <20160129.122437.2258453843319826058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 12:24 -0800, David Miller wrote:

> 
> This should be fixed now, thanks for letting me know.

Perfect, thanks !
