From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: lls fix build with allnoconfig
Date: Tue, 02 Jul 2013 23:53:12 -0700 (PDT)
Message-ID: <20130702.235312.1962706449684547854.davem@davemloft.net>
References: <20130703034124.28666.55448.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab3GCGxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 02:53:15 -0400
In-Reply-To: <20130703034124.28666.55448.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 03 Jul 2013 06:41:24 +0300

> correct placeholder declarations to prevent build breakage when
> !CONFIG_NET_LL_RX_POLL
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Applied, thanks.
