From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4: use one page fragment per incoming
 frame
Date: Mon, 03 Jun 2013 11:26:30 -0700
Message-ID: <1370283990.24311.180.camel@edumazet-glaptop>
References: <1370282095.24311.171.camel@edumazet-glaptop>
	 <51ACDAF5.2040008@hp.com> <1370283150.24311.179.camel@edumazet-glaptop>
	 <51ACDF70.4050301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:57343 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759674Ab3FCS0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:26:33 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so7861109obc.31
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 11:26:33 -0700 (PDT)
In-Reply-To: <51ACDF70.4050301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 11:24 -0700, Rick Jones wrote:

> I was thinking more about getting up to a socket and finding 
> insufficient overhead remaining to hold the packet.

Yes I got the point, and I answered to the question ;)
