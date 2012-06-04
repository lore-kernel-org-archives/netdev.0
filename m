From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 04 Jun 2012 22:18:55 +0200
Message-ID: <1338841135.2760.1964.camel@edumazet-glaptop>
References: <4FCCFE76.3060304@candelatech.com>
	 <1338838352.2760.1906.camel@edumazet-glaptop>
	 <4FCD16A4.9070705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49459 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757396Ab2FDUTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 16:19:00 -0400
Received: by bkcji2 with SMTP id ji2so3975624bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 13:18:59 -0700 (PDT)
In-Reply-To: <4FCD16A4.9070705@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 13:12 -0700, Ben Greear wrote:

> That sounds like a horrible hack :)
> 

Yep, but could be usefull on a gateway/router, if you cant change the
TCP stack of the clients.
