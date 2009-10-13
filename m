From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Mon, 12 Oct 2009 23:22:05 -0700 (PDT)
Message-ID: <20091012.232205.166353619.davem@davemloft.net>
References: <4AD41310.7040209@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932394AbZJMGWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 02:22:09 -0400
In-Reply-To: <4AD41310.7040209@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <Joyce.Yu@Sun.COM>
Date: Mon, 12 Oct 2009 22:41:36 -0700

> +++ b/drivers/net/niu.c
> @@ -3480,6 +3480,7 @@ static int niu_process_rx_pkt(struct napi_struct
> *napi, struct niu *np,

Your email client is still breaking up long lines.

Take your time and fix your setup correctly.  Read
'linux/Documentation/email-clients.txt' for tips.
