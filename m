From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] mac802154: llsec oversights
Date: Thu, 22 May 2014 15:24:47 -0400 (EDT)
Message-ID: <20140522.152447.1674550295961268352.davem@davemloft.net>
References: <1400584463-21692-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaEVTYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:24:48 -0400
In-Reply-To: <1400584463-21692-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Tue, 20 May 2014 13:14:21 +0200

> Fixes an unlock operation not matching a previous lock operation in
> an unlikely error path and removes a redundant check.

Series applied, thanks.
