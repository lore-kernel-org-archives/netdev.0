From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] ne: DeviceTree support.
Date: Mon, 05 Oct 2015 06:38:05 -0700 (PDT)
Message-ID: <20151005.063805.462470979021404810.davem@davemloft.net>
References: <1443765891-32589-1-git-send-email-ysato@users.sourceforge.jp>
	<1443765891-32589-2-git-send-email-ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ysato@users.sourceforge.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbJENWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:22:25 -0400
In-Reply-To: <1443765891-32589-2-git-send-email-ysato@users.sourceforge.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Fri,  2 Oct 2015 15:04:51 +0900

> +	if (dev->dev.of_node)

Please use "dev_of_node()".
