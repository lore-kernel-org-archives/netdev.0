From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v0 net-next 1/1] net/pch_gpe: Cannot disable ethernet
 autonegation
Date: Wed, 25 Jul 2012 15:25:06 -0700 (PDT)
Message-ID: <20120725.152506.2022148269560577883.davem@davemloft.net>
References: <1343218439-5403-1-git-send-email-w90p710@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w90p710@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab2GYWZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:25:07 -0400
In-Reply-To: <1343218439-5403-1-git-send-email-w90p710@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: w90p710@gmail.com
Date: Wed, 25 Jul 2012 20:13:59 +0800

> From: Wei Yang <w90p710@gmail.com>
> 
> When attempting to disable ethernet autonegation via ethtool,
> the pch_gpe driver will set software reset bit of PHY chip, But 
> control register of PHY chip of FRI2 will reenable ethernet autonegation.
> 
> Signed-off-by: Wei Yang <w90p710@gmail.com>

Applied.
