From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: remove unnecessary assignment
Date: Wed, 22 Jul 2009 21:04:48 -0700 (PDT)
Message-ID: <20090722.210448.246055243.davem@davemloft.net>
References: <392fb48f0907221953j77b8ea0etcad115f9b2c99c7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221AbZGWEEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 00:04:43 -0400
In-Reply-To: <392fb48f0907221953j77b8ea0etcad115f9b2c99c7b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Thu, 23 Jul 2009 11:53:58 +0900

> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

When people ACK your patches and they are still in
"Under Review" state in patchwork, you DO NOT have
to resend the patch.

When I grab it out of patchwork and apply it to my
tree patchwork has seen all of the Acked-by and other
tags in the replies and puts it into the commit
message for me.

By resending this you're making MORE work for me, not
LESS.
