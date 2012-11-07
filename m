From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: change TX coalescing defaults
Date: Wed, 07 Nov 2012 08:05:12 -0800
Message-ID: <1352304312.3140.4411.camel@edumazet-glaptop>
References: <1352168442.3140.32.camel@edumazet-glaptop>
	 <CAPcc5Pj0ffeb8O8YW3SAS21=+ub8ypc34=YaAxTB-qh9DGeawQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Vimalkumar <j.vimal@gmail.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61603 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab2KGQFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 11:05:15 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so1305604pbb.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 08:05:15 -0800 (PST)
In-Reply-To: <CAPcc5Pj0ffeb8O8YW3SAS21=+ub8ypc34=YaAxTB-qh9DGeawQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-07 at 17:30 +0200, Amir Vadai wrote:
> Acked.
> 
> BTW, a mail will be sent - I'm replacing Yevgeny Petrilin as mlx4_en maintainer.
> 

OK, thanks.

BTW proper way to Ack a patch so that its automatically taken into
account by tools is to use :

Acked-by: Amir Vadai <amirv@mellanox.com>
