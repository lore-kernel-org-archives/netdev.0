From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: hash key for rss-config cmd not set
Date: Tue, 24 May 2011 13:34:12 -0400 (EDT)
Message-ID: <20110524.133412.1214421180597680679.davem@davemloft.net>
References: <edb3e5b8-a38f-4efe-b267-9b5b332f16a4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911Ab1EXReR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:34:17 -0400
In-Reply-To: <edb3e5b8-a38f-4efe-b267-9b5b332f16a4@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 24 May 2011 11:59:09 +0530

> A non-zero, non-descript value is needed as the hash key. The hash variable was left un-initialized; but sometimes it gets a zero value
> and hashing is not effective. The constant value used now (not of any significance) seems to work fine.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
