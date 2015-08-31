From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] net: thunderx: New features and fixes
Date: Sun, 30 Aug 2015 21:54:26 -0700 (PDT)
Message-ID: <20150830.215426.1263274449496319755.davem@davemloft.net>
References: <1440926958-1874-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, david.daney@cavium.com,
	robert.richter@caviumnetworks.com,
	Sunil.Goutham@caviumnetworks.com, klimov.linux@gmail.com
To: aleksey.makarov@auriga.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbHaEy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 00:54:27 -0400
In-Reply-To: <1440926958-1874-1-git-send-email-aleksey.makarov@auriga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aleksey Makarov <aleksey.makarov@auriga.com>
Date: Sun, 30 Aug 2015 12:29:08 +0300

> v2:
>   - The unused affinity_mask field of the structure cmp_queue 
>   has been deleted. (thanks to David Miller)
>   - The unneeded initializers have been dropped. (thanks to Alexey Klimov)
>   - The commit message "net: thunderx: Rework interrupt handling"
>   has been fixed. (thanks to Alexey Klimov)

Series applied, thanks.
