From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN:Add check for return value of pnp_activate_dev()
Date: Wed, 18 Jul 2012 09:42:30 -0700 (PDT)
Message-ID: <20120718.094230.1144940254281009359.davem@davemloft.net>
References: <1342110562-7774-1-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	rucsoftsec@gmail.com
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083Ab2GRQma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:42:30 -0400
In-Reply-To: <1342110562-7774-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Thu, 12 Jul 2012 18:29:22 +0200

> pnp_activate_dev() return value needs to be checked to make sure that
> following calls calls to the PNP functions do work correctly.
> Fix for report #44491 on bugzilla.kernel.org.
> 
> Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>

Applied.
