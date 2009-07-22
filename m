From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Bug fix in the non-lro path. Size of received
 packet was not updated in statistics properly.
Date: Wed, 22 Jul 2009 09:29:05 -0700 (PDT)
Message-ID: <20090722.092905.212866175.davem@davemloft.net>
References: <20090722111933.GA22465@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbZGVQ27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 12:28:59 -0400
In-Reply-To: <20090722111933.GA22465@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 22 Jul 2009 16:49:44 +0530

> This patch fixes a bug in the non-lro path. 
> Wrong size of received packet was being passed for updating receive statistics.
> This patch is against the net-2.6 git.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
