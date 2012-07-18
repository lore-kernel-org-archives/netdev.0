From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] asix: Fix return value in AX88172A driver
 bind function
Date: Wed, 18 Jul 2012 09:33:16 -0700 (PDT)
Message-ID: <20120718.093316.829671412155849909.davem@davemloft.net>
References: <1342609012-3075-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab2GRQdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:33:16 -0400
In-Reply-To: <1342609012-3075-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Wed, 18 Jul 2012 12:56:52 +0200

> Return -ENOTSUPP if the initialization fails because the
> device is configured for a mode that is not supported by the driver.
> 
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>

Applied, thanks.
