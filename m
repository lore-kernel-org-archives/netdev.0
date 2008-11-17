From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Sun, 16 Nov 2008 19:45:05 -0800 (PST)
Message-ID: <20081116.194505.140648013.davem@davemloft.net>
References: <200811171344.57410.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbYKQDpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:45:06 -0500
In-Reply-To: <200811171344.57410.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 17 Nov 2008 13:44:57 +1030

> @@ -82,6 +82,16 @@ static void give_a_page(struct virtnet_info *vi, struct 
> page *page)

-E_EMAIL_CLIENT_NEWLINES
