From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 1/1] DSA: Enable cascading in multi-chip 6131
 configuration
Date: Wed, 29 Jun 2011 05:54:03 -0700 (PDT)
Message-ID: <20110629.055403.1350939152802360182.davem@davemloft.net>
References: <1308981231-2561-1-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: barry@grussling.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755439Ab1F2MyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 08:54:08 -0400
In-Reply-To: <1308981231-2561-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>
Date: Fri, 24 Jun 2011 22:53:51 -0700

> From: Barry Grussling <barry@grussling.com>
> 
> This patch enables the 6131 family of chips to forward DSA
> packets to other switch chips.  This is needed if multiple
> DSA chips are used in a device.  Without this patch the
> chip will drop any DSA packets not destined for it.
> 
> This patch only enables the forwarding of DSA packets if
> multiple chips are used in the switch configuration.
> 
> Signed-off-by: Barry Grussling <barry@grussling.com>

Applied.
