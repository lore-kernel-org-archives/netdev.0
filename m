From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/3] Fix Ethernet jumbo frames support for Armada
 370 and 38x
Date: Tue, 30 Jun 2015 09:37:38 -0700 (PDT)
Message-ID: <20150630.093738.48589191219422826.davem@davemloft.net>
References: <1435674022-13295-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, gregory.clement@free-electrons.com,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, vdonnefort@gmail.com
To: simon.guinot@sequanux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbF3Qhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 12:37:42 -0400
In-Reply-To: <1435674022-13295-1-git-send-email-simon.guinot@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Guinot <simon.guinot@sequanux.org>
Date: Tue, 30 Jun 2015 16:20:19 +0200

> This patch series fixes the Ethernet jumbo frames support for the SoCs
> Armada 370, 380 and 385. Unlike Armada XP, the Ethernet controller for
> this SoCs don't support TCP/IP checksumming with a frame size larger
> than 1600 bytes.
> 
> This patches should be applied to the -stable kernels 3.8 and onwards.

Series applied, thanks.
