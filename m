From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] pcnet32: add missing check for
 pci_dma_mapping_error
Date: Wed, 19 Feb 2014 14:59:48 -0500 (EST)
Message-ID: <20140219.145948.614873854032013591.davem@davemloft.net>
References: <1392699479.4020.28.camel@Linux>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pcnet32@frontier.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099AbaBST7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:59:50 -0500
In-Reply-To: <1392699479.4020.28.camel@Linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@frontier.com>
Date: Mon, 17 Feb 2014 20:57:59 -0800

> The pci_map_single calls never checked for error. Add error checking
> as requested by someone last year.  Tested on 79c972.
> 
> Signed-off-by: Don Fry <pcnet32@frontier.com>

Applied.
