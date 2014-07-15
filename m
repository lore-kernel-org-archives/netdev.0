From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ethernet: mvpp2: Fix build breakage
Date: Tue, 15 Jul 2014 16:07:37 -0700 (PDT)
Message-ID: <20140715.160737.1045577706537774063.davem@davemloft.net>
References: <1405422365-6214-1-git-send-email-sachin.kamat@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, spk.linux@gmail.com, mw@semihalf.com,
	ezequiel.garcia@free-electrons.com
To: sachin.kamat@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759331AbaGOXHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:07:38 -0400
In-Reply-To: <1405422365-6214-1-git-send-email-sachin.kamat@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sachin Kamat <sachin.kamat@samsung.com>
Date: Tue, 15 Jul 2014 16:36:05 +0530

> A missing space in the module license string caused the following error
> while doing a modular build.
> FATAL: modpost: GPL-incompatible module mvpp2.ko uses GPL-only symbol 'platform_driver_unregister'
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@samsung.com>
> Cc: Marcin Wojtas <mw@semihalf.com>
> Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Ezequiel sent me a similar fix first, so I applied his copy just now.

Thanks.
