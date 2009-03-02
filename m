From: David Miller <davem@davemloft.net>
Subject: Re: PATCH tcp_init_wl / tcp_update_wl argument cleanup
Date: Mon, 02 Mar 2009 03:14:01 -0800 (PST)
Message-ID: <20090302.031401.177327405.davem@davemloft.net>
References: <49AA657B.5030904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ithilgore.ryu.l@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752103AbZCBLOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:14:19 -0500
In-Reply-To: <49AA657B.5030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "ithilgore.ryu.L@gmail.com" <ithilgore.ryu.l@gmail.com>
Date: Sun, 01 Mar 2009 12:37:47 +0200

> The above functions from include/net/tcp.h have been defined with an
> argument that they never use. The argument is 'u32 ack' which is never
> used inside the function body, and thus it can be removed. The rest of
> the patch involves the necessary changes to the function callers of the
> above two functions.

Please read linux/Documentation/SubmittingPatches

In particular, your submission:

1) Lacked a proper "Signed-off-by" line and please do fix
   the proper name assosciated with your email address if
   you don't mind.

2) Did not root your patch properly.

Thanks.
