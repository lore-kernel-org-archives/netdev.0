From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] mlx4: use napi_complete_done()
Date: Mon, 10 Nov 2014 10:01:28 -0800
Message-ID: <1415642488.9613.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415337011.13896.103.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141107.170053.1003349690694025765.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	willemb@google.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:41182 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbaKJSBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:01:31 -0500
Received: by mail-ie0-f177.google.com with SMTP id tp5so9349815ieb.8
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 10:01:30 -0800 (PST)
In-Reply-To: <20141107.170053.1003349690694025765.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-07 at 17:00 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 06 Nov 2014 21:10:11 -0800
...
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

I managed to add a bug in this trivial patch.

I'll send a fix asap.
