From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] fec_mpc52xx: fix error path
Date: Thu, 08 Jul 2010 23:44:42 -0700 (PDT)
Message-ID: <20100708.234442.68149385.davem@davemloft.net>
References: <1278591018-3724-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, grant.likely@secretlab.ca,
	jpirko@redhat.com, eric.dumazet@gmail.com, smaclennan@pikatech.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308Ab0GIGoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:44:30 -0400
In-Reply-To: <1278591018-3724-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Thu,  8 Jul 2010 16:10:16 +0400

> Error path in mpc52xx_fec_probe() is broken.
> We must free everything that we've allocated.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Also applied, thanks.
