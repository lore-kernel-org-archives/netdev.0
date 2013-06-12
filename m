From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: remove is_data also from ip_options
 documentation.
Date: Wed, 12 Jun 2013 03:14:09 -0700 (PDT)
Message-ID: <20130612.031409.235157227621887141.davem@davemloft.net>
References: <1370874429-4458-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab3FLKOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 06:14:10 -0400
In-Reply-To: <1370874429-4458-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon, 10 Jun 2013 17:27:09 +0300

> commit ef722495c8867aacc1db0675a6737e5cf1e72e07 removed the unused is_data
> member from ip_options struct.
> 
> This patch removes is_data also from the documentation of the ip_options struct.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.
