From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: davicom: add IDs for DM9161B and C
 variants
Date: Thu, 11 Jun 2015 00:29:26 -0700 (PDT)
Message-ID: <20150611.002926.884088890121725599.davem@davemloft.net>
References: <1433954900-25419-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gustavo@zacarias.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbFKH31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:29:27 -0400
In-Reply-To: <1433954900-25419-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Date: Wed, 10 Jun 2015 13:48:20 -0300

> Add PHY IDs for Davicom DM9161B and DM9161C variants.
> Tested with a DM9161C on a custom Atmel-based SAM9X25 board in RMII
> mode.
> 
> The DM9161B uses the same model id with just the LSB bit of the version
> id changing (which is masked out).
> 
> For all intents and purposes they're the same as the DM9161A with an
> added GPSI mode and better fabrication process.
> 
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>

Applied, thanks.
