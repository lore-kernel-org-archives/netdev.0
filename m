From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Mon, 12 Oct 2009 16:52:47 -0700 (PDT)
Message-ID: <20091012.165247.125878928.davem@davemloft.net>
References: <4AD3BB3C.2010805@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce.Yu@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbZJLXwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 19:52:51 -0400
In-Reply-To: <4AD3BB3C.2010805@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <Joyce.Yu@Sun.COM>
Date: Mon, 12 Oct 2009 16:26:52 -0700

> @@ -3480,6 +3480,7 @@ static int niu_process_rx_pkt(struct napi_struct
> *napi, struct niu *np,

Your patch was corrupted by your email client, it breaks up long lines
and turns tab characters into spaces.

Please fix this up and resubmit.
