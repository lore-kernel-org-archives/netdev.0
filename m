From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] MAINTAINERS: NETWORKING DRIVERS matches too much
Date: Tue, 23 Oct 2012 02:33:21 -0400 (EDT)
Message-ID: <20121023.023321.1875030623621221340.davem@davemloft.net>
References: <20121018221138.66b43fed@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, akpm@linux-foundation.org
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab2JWGdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:33:22 -0400
In-Reply-To: <20121018221138.66b43fed@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>
Date: Thu, 18 Oct 2012 22:11:38 +0200

> File pattern include/linux/*device.h matches too much, including
> completely unrelated files. Replace it with an explicit list of
> network device-related header files.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Cc: Joe Perches <joe@perches.com>
> Acked-by: David S. Miller <davem@davemloft.net>

Applied, thanks Jean.
