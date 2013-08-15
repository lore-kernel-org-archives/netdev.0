From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Thu, 15 Aug 2013 13:17:10 -0700 (PDT)
Message-ID: <20130815.131710.1964952430529709863.davem@davemloft.net>
References: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
	<20130815.010726.719593168454341579.davem@davemloft.net>
	<520D10CA.7040600@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com,
	shangw@linux.vnet.ibm.com, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308Ab3HOURK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 16:17:10 -0400
In-Reply-To: <520D10CA.7040600@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Thu, 15 Aug 2013 10:32:58 -0700

> Sorry, I forgot to add Michael's Signed-off-by. Do you want me to
> resend it with his Signed-off-by added?

That's not necessary, it gets added automatically by patchwork
since he replied and added it.
