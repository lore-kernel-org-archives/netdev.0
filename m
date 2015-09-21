From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: check for dma mapping errors
Date: Sun, 20 Sep 2015 21:37:13 -0700 (PDT)
Message-ID: <20150920.213713.2280384805982820360.davem@davemloft.net>
References: <1442410063-30635-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbIUEhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 00:37:14 -0400
In-Reply-To: <1442410063-30635-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed, 16 Sep 2015 15:27:43 +0200

> Check for DMA mapping errors, recover from them and register them in
> ethtool stats like other errors.
> 
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
