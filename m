From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Fail driver load in 100g MSI mode.
Date: Mon, 01 Aug 2016 22:14:21 -0700 (PDT)
Message-ID: <20160801.221421.237230426877949189.davem@davemloft.net>
References: <1470056893-16415-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbcHBF0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 01:26:04 -0400
In-Reply-To: <1470056893-16415-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Mon, 1 Aug 2016 09:08:13 -0400

> 100g support is not available in MSI mode. Failing the driver load in this scenario.
> 
> Please consider applying this to `net'.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
