From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] gianfar: wol magic packet fixes
Date: Fri, 31 Jul 2015 15:42:19 -0700 (PDT)
Message-ID: <20150731.154219.2213544232353514077.davem@davemloft.net>
References: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbGaWmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:42:20 -0400
In-Reply-To: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 31 Jul 2015 18:38:30 +0300

> These changes were already validated as part of FSL SDK.
> Patch 2 fixes occasional wake-on magic packet failures during
> traffic, probably due to incorrect traffic stop/ device halt
> sequence and incorrect usage of txlock.

Series applied, thanks.
