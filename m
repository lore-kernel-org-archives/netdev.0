From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix docbook warning for IFF_VRF_MASTER enum
Date: Mon, 17 Aug 2015 15:56:59 -0700 (PDT)
Message-ID: <20150817.155659.1290906708731655035.davem@davemloft.net>
References: <201508141519.mrm1TF6u%fengguang.wu@intel.com>
	<1439742409-3482-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbbHQW5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:57:00 -0400
In-Reply-To: <1439742409-3482-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 16 Aug 2015 10:26:49 -0600

> kbuild test robot reported:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   d52736e24fe2e927c26817256f8d1a3c8b5d51a0
> commit: 4e3c89920cd3a6cfce22c6f537690747c26128dd [751/762] net: Introduce VRF related flags and helpers
> reproduce: make htmldocs
> 
>>> Warning(include/linux/netdevice.h:1293): Enum value 'IFF_VRF_MASTER' not described in enum 'netdev_priv_flags'
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
