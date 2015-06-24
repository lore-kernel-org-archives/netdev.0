From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: use atomic_t instead of spin_lock in
 busy poll
Date: Wed, 24 Jun 2015 05:44:27 -0700 (PDT)
Message-ID: <20150624.054427.637047670629153404.davem@davemloft.net>
References: <1435076270-14166-1-git-send-email-_govind@gmx.com>
	<20150624.012501.1398638370458478294.davem@davemloft.net>
	<alpine.LNX.2.03.1506241401180.24620@ws.cisco>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbFXMcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 08:32:36 -0400
In-Reply-To: <alpine.LNX.2.03.1506241401180.24620@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 24 Jun 2015 15:56:17 +0530 (IST)

> Let me know if this change is OK, I will send new patch with detailed
> description.

Yes, and please do.
