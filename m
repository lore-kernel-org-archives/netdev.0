From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock
 contention
Date: Thu, 14 May 2015 14:46:32 -0400 (EDT)
Message-ID: <20150514.144632.514885310313332490.davem@davemloft.net>
References: <1431620686.27831.63.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150514.125922.1722914809373007896.davem@davemloft.net>
	<CA+FuTSesrSiC84pDVR=0r9uhsM5UHuQpJ=hYLvBjafOtTGUfLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933129AbbENSqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 14:46:35 -0400
In-Reply-To: <CA+FuTSesrSiC84pDVR=0r9uhsM5UHuQpJ=hYLvBjafOtTGUfLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 14 May 2015 14:35:57 -0400

> This looks great, thanks. I can submit it, but it is essentially your fix.

Just give me your Acked-by: and I'll apply my patch then.

Thanks.
