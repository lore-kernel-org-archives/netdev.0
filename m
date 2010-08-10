From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] caif-spi: Bugfix SPI_DATA_POS settings were
 inverted.
Date: Tue, 10 Aug 2010 16:39:49 -0700 (PDT)
Message-ID: <20100810.163949.241460562.davem@davemloft.net>
References: <1281461807-17408-1-git-send-email-sjur.brandeland@stericsson.com>
	<1281461807-17408-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjurbren@gmail.com, netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751881Ab0HJXj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 19:39:29 -0400
In-Reply-To: <1281461807-17408-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Tue, 10 Aug 2010 19:36:47 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> The setting of SPI_DATA_POS depending on CONFIG_CAIF_SPI_SYNC
> where inverted.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
