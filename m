From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Add support for ethtool self test
Date: Thu, 03 Dec 2009 16:16:10 -0800 (PST)
Message-ID: <20091203.161610.161620904.davem@davemloft.net>
References: <20091204001409.GA4609@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754258AbZLDAQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:16:03 -0500
In-Reply-To: <20091204001409.GA4609@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 4 Dec 2009 05:44:18 +0530

> This patch adds support for ethtool selftest.
> 
> From: Suresh R <sureshr@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied, but can you tell me where the ->self_test_count
thing came from?
