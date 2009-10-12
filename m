From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mm] connector: Passing required parameter for function
 cn_add_callback.
Date: Sun, 11 Oct 2009 22:35:02 -0700 (PDT)
Message-ID: <20091011.223502.77690228.davem@davemloft.net>
References: <b9df5fa10910111944s274207aica39c0e646c10f7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, zbr@ioremap.net,
	linux-kernel@vger.kernel.org
To: rakib.mullick@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46122
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751196AbZJLFfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 01:35:07 -0400
In-Reply-To: <b9df5fa10910111944s274207aica39c0e646c10f7a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rakib Mullick <rakib.mullick@gmail.com>
Date: Mon, 12 Oct 2009 08:44:33 +0600

>   */
> -static void cn_proc_mcast_ctl(struct cn_msg *msg)
> +static void cn_proc_mcast_ctl(struct cn_msg *msg, struct
> netlink_skb_parms *nsp)

Your patches are unusable because your email client corrupts the
patch, here you can see it is splitting up long lines.

Please fix this up and resubmit.
