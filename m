From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4 v2] netdev: bfin_mac: fix performance issue found
 by netperf
Date: Fri, 29 May 2009 15:49:54 -0700 (PDT)
Message-ID: <20090529.154954.68640365.davem@davemloft.net>
References: <20090529.020554.107005632.davem@davemloft.net>
	<1243604475-27246-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	michael.hennerich@analog.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbZE2Wty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:49:54 -0400
In-Reply-To: <1243604475-27246-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 29 May 2009 09:41:15 -0400

> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> - Remove dead long delay
> - Use proper defines
> - Remove broken implementation of the TX DMA Data Alignment TXDWA feature
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

Applied to net-next-2.6
